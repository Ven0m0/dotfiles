# usr/ - System-Wide User Programs

This directory contains system-wide binaries and libraries deployed to `/usr` using `tuckr`.

## Structure

```
usr/
├── local/
│   ├── bin/     # Custom system-wide binaries
│   └── lib/     # Custom system-wide libraries
└── share/       # System-wide data files
```

## Deployment

These files are symlinked to `/usr` using tuckr:

```bash
sudo tuckr link -d $(yadm rev-parse --show-toplevel) -t / usr
```

## What Goes Here

- System-wide scripts that all users should access
- Custom binaries installed for the entire system
- Shared libraries and data files

## What Does NOT Go Here

- User-specific binaries → Use `Home/.local/bin/`
- Configuration files → Use `etc/` instead
- Package manager-installed files → Managed by pacman/apt
