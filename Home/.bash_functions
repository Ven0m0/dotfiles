# -----------------------------------------------------------------------------
# .bash_functions - Optimized & Handy Shell Functions
# -----------------------------------------------------------------------------
# Create a directory and cd into it immediately
# Improvement: Handles nested directories (-p) and quotes for safety
mkcd(){
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"; return 1
  fi
  mkdir -p "$1" && cd "$1" || return 1
}
# Smart archive extractor
# Improvement: Uses a case statement for efficiency and covers common formats
extract(){
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
# Go up N directories
# Improvement: Faster than typing "cd ../../../"
up(){
  local d="" limit=$1
  for ((i=1 ; i <= limit ; i++)); do
    d=$d/..
  done
  d=$(echo $d | sed 's/^\///')
  if [[ -z "$d" ]]; then
    d=..
  fi
  cd $d
}
# Quick backup of a file
# Improvement: Uses standard naming convention (file.bak)
backup(){
  if [[ -f "$1" ]]; then
    cp "$1" "${1}.bak"
    echo "Backed up $1 to ${1}.bak"
  else
    echo "File $1 not found."
  fi
}
