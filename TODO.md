**Quick web server serving current dir**

```bash
# https://catonmat.net/top-ten-one-liners-from-commandlinefu-explained
alias pyserver='python3 -m SimpleHTTPServer 8000'
```

**Find files**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   find_files "/search/dir" png jpg jpeg results_array
#   Then results_array will contain the matching files as a Bash array.

find_files(){
  local search_dir="$1"; shift
  local exts=()
  # Collect all extensions except the last argument
  while (( $# > 1 )); do
    exts+=("$1")
    shift
  done
  local -n result_array=$1

  if command -v fd >/dev/null 2>&1; then
    local fd_args=()
    for ext in "${exts[@]}"; do fd_args+=( -e "$ext" ); done
    mapfile -d '' result_array < <(fd --hidden --follow --no-ignore --color=never --absolute-path --print0 -I "${fd_args[@]}" . "$search_dir")
  else
    local find_expr=()
    for ext in "${exts[@]}"; do find_expr+=( -iname "*.${ext}" -o ); done
    # Remove trailing -o
    unset 'find_expr[${#find_expr[@]}-1]'
    mapfile -d '' result_array < <(find -O3 "$search_dir" -type f \( "${find_expr[@]}" \) -print0)
  fi
}

# Example usage:
search_dir="/path/to/search"

find_files "$search_dir" png png_files
find_files "$search_dir" jpg jpeg jpeg_files

echo "Found ${#png_files[@]} PNG files:"
for f in "${png_files[@]}"; do
  echo "  $f"
done

echo "Found ${#jpeg_files[@]} JPEG files:"
for f in "${jpeg_files[@]}"; do
  echo "  $f"
done
```

**Pacman modules**
```
/usr/share/libalpm/scripts/
```
