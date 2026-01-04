#!/usr/bin/env python3 -OO
"""
SteelSeries HID device permission setter for udev.
Parses HID report descriptors to identify vendor/consumer devices.
Usage: steelseries-perms.py <hidraw_device> [--dry-run]
"""
import ctypes
import fcntl
import os
import struct
import sys
from dataclasses import dataclass
from pathlib import Path

# HID constants from Linux kernel headers
_IOC_NRBITS = 8
_IOC_TYPEBITS = 8
_IOC_SIZEBITS = 14
_IOC_NRSHIFT = 0
_IOC_TYPESHIFT = _IOC_NRSHIFT + _IOC_NRBITS
_IOC_SIZESHIFT = _IOC_TYPESHIFT + _IOC_TYPEBITS
_IOC_DIRSHIFT = _IOC_SIZESHIFT + _IOC_SIZEBITS
_IOC_READ = 2
HID_MAX_DESCRIPTOR_SIZE = 4096


def _ioc(direction: int, type_: str, nr: int, size: int) -> int:
  return (
    (direction << _IOC_DIRSHIFT)
    | (ord(type_) << _IOC_TYPESHIFT)
    | (nr << _IOC_NRSHIFT)
    | (size << _IOC_SIZESHIFT)
  )


def _ior(type_: str, nr: int, size: int) -> int:
  return _ioc(_IOC_READ, type_, nr, size)


HIDIOCGRDESCSIZE = _ior("H", 0x01, ctypes.sizeof(ctypes.c_uint))
HIDIOCGRDESC = _ior("H", 0x02, ctypes.sizeof(ctypes.c_uint) + HID_MAX_DESCRIPTOR_SIZE)


@dataclass(slots=True, frozen=True)
class HIDDescriptor:
  """HID report descriptor with size and data."""
  size: int
  data: bytes


class HIDRawReportDescriptor(ctypes.Structure):
  """C structure for HIDIOCGRDESC ioctl."""
  _fields_ = [
    ("size", ctypes.c_uint),
    ("value", ctypes.c_uint8 * HID_MAX_DESCRIPTOR_SIZE),
  ]


def log(msg: str) -> None:
  """Log to stderr for udev visibility."""
  print(f"steelseries-perms: {msg}", file=sys.stderr, flush=True)


def get_hid_descriptor(device_path: str) -> HIDDescriptor:
  """Retrieve HID report descriptor via ioctl."""
  try:
    with Path(device_path).open("rb") as fd:
      size = ctypes.c_uint()
      fcntl.ioctl(fd.fileno(), HIDIOCGRDESCSIZE, size, True)
      
      if size.value == 0 or size.value > HID_MAX_DESCRIPTOR_SIZE:
        raise ValueError(f"Invalid descriptor size: {size.value}")
      
      desc_struct = HIDRawReportDescriptor()
      desc_struct.size = size.value
      fcntl.ioctl(fd.fileno(), HIDIOCGRDESC, desc_struct, True)
      
      return HIDDescriptor(
        size=size.value,
        data=bytes(desc_struct.value[:size.value])
      )
  except (OSError, IOError) as e:
    raise RuntimeError(f"Failed to read HID descriptor: {e}") from e


def parse_usage_page(descriptor: bytes) -> int:
  """
  Parse HID descriptor to extract first usage page.
  Returns 0 if not found.
  """
  i = 0
  while i < len(descriptor):
    if i >= len(descriptor):
      break
    
    b0 = descriptor[i]
    
    # Long item: skip (shouldn't be usage page)
    if b0 == 0xFE:
      if i + 1 >= len(descriptor):
        break
      i += 3 + descriptor[i + 1]
      continue
    
    # Parse short item
    tag = (b0 >> 4) & 0x0F
    item_type = (b0 >> 2) & 0x03
    size = b0 & 0x03
    size = 2 ** (size - 1) if size else 0
    
    # Usage page (type=1, tag=0)
    if item_type == 1 and tag == 0:
      if i + 1 + size > len(descriptor):
        break
      
      fmt = {1: "B", 2: "H", 4: "I"}.get(size)
      if not fmt:
        log(f"Invalid usage page size: {size}")
        break
      
      return struct.unpack_from(fmt, descriptor, i + 1)[0]
    
    i += 1 + size
  
  return 0


def should_allow_access(usage_page: int) -> bool:
  """Check if usage page indicates vendor/consumer device."""
  # Consumer Control (0x000C) or Vendor-defined (0xFF00-0xFFFF)
  return usage_page == 0x000C or usage_page >= 0xFF00


def set_device_permissions(device_path: str, mode: int = 0o666, dry_run: bool = False) -> None:
  """Set device permissions after validation."""
  if dry_run:
    log(f"[DRY-RUN] Would chmod {oct(mode)} on {device_path}")
    return
  
  try:
    os.chmod(device_path, mode)
    log(f"Set permissions {oct(mode)} on {device_path}")
  except OSError as e:
    raise RuntimeError(f"Failed to set permissions: {e}") from e


def main() -> int:
  if len(sys.argv) < 2:
    log("Usage: steelseries-perms.py <hidraw_device> [--dry-run]")
    return 1
  
  device_path = sys.argv[1]
  dry_run = "--dry-run" in sys.argv
  
  if not Path(device_path).exists():
    log(f"Device not found: {device_path}")
    return 1
  
  try:
    descriptor = get_hid_descriptor(device_path)
    usage_page = parse_usage_page(descriptor.data)
    
    log(f"Device {device_path}: usage_page=0x{usage_page:04X}")
    
    if should_allow_access(usage_page):
      set_device_permissions(device_path, dry_run=dry_run)
    else:
      log(f"Skipped (usage page 0x{usage_page:04X} not vendor/consumer)")
    
    return 0
    
  except (RuntimeError, ValueError) as e:
    log(f"Error: {e}")
    return 1


if __name__ == "__main__":
  sys.exit(main())
