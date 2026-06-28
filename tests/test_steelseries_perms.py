import importlib.util
import os
import pathlib
from unittest.mock import patch

import pytest

# Load the script as a module
script_path = pathlib.Path("etc/udev/rules.d/steelseries-perms.py")
spec = importlib.util.spec_from_file_location("steelseries_perms", script_path)
steelseries_perms = importlib.util.module_from_spec(spec)
spec.loader.exec_module(steelseries_perms)

def test_parse_usage_page_empty():
    assert steelseries_perms.parse_usage_page(b"") == 0

def test_parse_usage_page_1byte():
    # Usage Page (Generic Desktop) - 0x05 0x01
    assert steelseries_perms.parse_usage_page(b"\x05\x01") == 0x01

def test_parse_usage_page_2byte():
    # Usage Page (Vendor 0xFF00) - 0x06 0x00 0xFF
    assert steelseries_perms.parse_usage_page(b"\x06\x00\xFF") == 0xFF00

def test_parse_usage_page_4byte():
    # Usage Page (32-bit) - 0x07 0x11 0x22 0x33 0x44
    assert steelseries_perms.parse_usage_page(b"\x07\x11\x22\x33\x44") == 0x44332211

def test_parse_usage_page_long_item():
    # Long Item (1 byte data) - 0xFE 0x01 0x99 0xAA followed by Usage Page 0x05 0x0C
    # i=0: 0xFE, i=1: 0x01 (size), i=2: 0x99 (tag), i=3: 0xAA (data)
    # i += 3 + 1 = 4.
    # i=4 is 0x05.
    descriptor = b"\xFE\x01\x99\xAA\x05\x0C"
    assert steelseries_perms.parse_usage_page(descriptor) == 0x0C

def test_parse_usage_page_not_first():
    # Usage (0x09 0x01) followed by Usage Page (0x05 0x01)
    assert steelseries_perms.parse_usage_page(b"\x09\x01\x05\x01") == 0x01

def test_should_allow_access():
    assert steelseries_perms.should_allow_access(0x000C) is True
    assert steelseries_perms.should_allow_access(0xFF00) is True
    assert steelseries_perms.should_allow_access(0xFFFF) is True
    assert steelseries_perms.should_allow_access(0x0001) is False
    assert steelseries_perms.should_allow_access(0x0000) is False

def test_parse_usage_page_malformed():
    # Truncated item
    assert steelseries_perms.parse_usage_page(b"\x05") == 0
    # Truncated long item
    assert steelseries_perms.parse_usage_page(b"\xFE") == 0
    assert steelseries_perms.parse_usage_page(b"\xFE\x01") == 0

def test_set_device_permissions_error():
    with patch("os.chmod") as mock_chmod:
        mock_chmod.side_effect = OSError("Permission denied")
        with pytest.raises(RuntimeError, match="Failed to set permissions"):
            steelseries_perms.set_device_permissions("/dev/hidraw0")
