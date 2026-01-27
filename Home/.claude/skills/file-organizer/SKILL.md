---
name: file-organizer
description: "Organize files and folders intelligently. Auto-triggers on: organize files, cleanup downloads, find duplicates, folder structure, declutter, archive files, sort files."
triggers: [organize files, cleanup, duplicates, folder structure, declutter, archive, sort files, downloads]
related: [bash-optimizer, modern-tool-substitution]
---

# File Organizer

Organization assistant for clean, logical file structures.

## When to Use
- Downloads folder chaotic
- Can't find scattered files
- Duplicate files taking space
- Need better folder structure
- Cleaning before archive

## Quick Commands

```
Organize Downloads - move docs to Documents, images to Pictures, archive old files
Find duplicates in Documents
Review Projects - separate active from archived
Desktop cleanup - organize into Documents
Organize photos by date (EXIF)
```

## Workflow

### 1. Understand Scope
- Which directory?
- Main problem? (Can't find, duplicates, messy?)
- Files to avoid?
- How aggressive?

### 2. Analyze
```bash
fd -t f . [target] | head -20                    # File list
du -sh [target]/* | sort -rh | head -20          # Size
fd -t f . [target] -x basename | sort | uniq -c  # Extensions
```

### 3. Find Duplicates
```bash
fd -t f . [dir] -x md5sum | sort | uniq -d       # By hash
fd -t f . [dir] -x basename | sort | uniq -d     # Same name
```

### 4. Propose Plan
```markdown
# Organization Plan

## Current: X files, [size]
## Proposed Structure:
├── Work/Projects/ Documents/
├── Personal/Photos/ Documents/
└── Archive/

## Changes:
1. Create folders
2. Move: PDFs → Work/Documents/, images → Personal/Photos/
3. Delete: [duplicates]

Ready? (yes/no/modify)
```

### 5. Execute with Logging
```bash
mkdir -p "path/to/folders"
mv "old" "new"  # Log all moves for undo
```

## Best Practices

**Folder naming:** Clear, no spaces, specific (client-proposals not docs)
**File naming:** Include dates (2024-10-17-meeting-notes.md)
**Archive when:** Not touched 6+ months, completed work, old versions
