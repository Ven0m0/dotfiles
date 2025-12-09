#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C

has(){ command -v -- "$1" &>/dev/null;}
die(){ printf 'ERROR: %s\n' "$*" >&2;exit 1;}
need(){ has "$1" || die "Required: $1";}
if has jaq;then JQ=jaq;elif has jq;then JQ=jq;else JQ='';fi
[[ -n $JQ ]] || die "jq/jaq required"

usage(){
  cat <<'EOF'
gh-tools - GitHub utilities
USAGE:
  gh-tools COMMAND [ARGS...]
COMMANDS:
  asset OWNER/REPO PATTERN     Download release asset
  install OWNER/REPO           Interactive install from release
  maint [MODE] [OPTIONS]       Git repository maintenance
  -h, --help                   Show help
ASSET OPTIONS:
  -r TAG          Specific release (default: latest)
  -o FILE         Output filename
  -s, --silent    Silent mode
INSTALL OPTIONS:
  -t TAG          Specific tag/version
  -p PATH         Install path (default: $HOME/.local/bin)
MAINT MODES:
  clean           Clean merged branches
  update          Update from remote
  both            Update then clean (default)
MAINT OPTIONS:
  -d, --dry-run   Show actions without executing
  -y, --yes       Auto-confirm deletions
  -v, --verbose   Verbose output
EXAMPLES:
  gh-tools asset chmouel/gosmee Linux-ARM64.rpm
  gh-tools asset -r v1.2.3 -o /tmp/file.zip user/repo asset.zip
  gh-tools install user/repo
  gh-tools install -t v1.0.0 -p /usr/local/bin user/repo
  gh-tools maint clean -y
  gh-tools maint both --dry-run
EOF
}
# ============================================================================
# ASSET
# ============================================================================
cmd_asset(){
  need curl
  local release="" output_opt=(-O) curl_args=(-fsSL)
  while getopts "r:so:h" opt;do
    case "$opt" in
      r) release="$OPTARG";;
      s) curl_args+=(-s);;
      o) output_opt=(-o "$OPTARG");;
      h) usage;exit 0;;
      *) die "Invalid option";;
    esac
  done
  shift $((OPTIND-1))
  [[ $# -eq 2 ]] || die "Usage: gh-tools asset OWNER/REPO PATTERN"
  local repo="$1" substring="$2" TMP=$(mktemp)
  trap 'rm -f "$TMP"' EXIT
  curl -fsSL -o "$TMP" "https://api.github.com/repos/${repo}/releases"
  local selector='.[0]'
  [[ -n $release ]] && selector=".[]|select(.tag_name==\"${release}\")"
  local -a assets
  mapfile -t assets < <("$JQ" -rM "${selector}.assets[]|select(.name|contains(\"${substring}\"))?|.browser_download_url" <"$TMP")
  [[ ${#assets[@]} -eq 0 ]] && die "No asset matching '${substring}' in ${repo}"
  for asset in "${assets[@]}";do
    printf 'Downloading: %s\n' "$asset"
    curl "${output_opt[@]}" "${curl_args[@]}" "$asset"
  done
  printf '✓ Complete\n'
}
# ============================================================================
# INSTALL
# ============================================================================
cmd_install(){
  need gh
  local tag="" binpath="${GH_BINPATH:-$HOME/.local/bin}" TMP="/tmp/.gh-install"
  while getopts "t:p:h" opt;do
    case "$opt" in
      t) tag="$OPTARG";;
      p) binpath="$OPTARG";;
      h) usage;exit 0;;
      *) die "Invalid option";;
    esac
  done
  shift $((OPTIND-1))
  [[ $# -eq 1 ]] || die "Usage: gh-tools install OWNER/REPO"
  local repo="$1"
  choose(){
    if has fzf;then
      printf '%s\n' "$@"|fzf --height 10 --prompt "$PS3" -1
    else
      select opt in "$@";do break;done
      printf '%s' "$opt"
    fi
  }
  extract(){
    local arg="$1"
    [[ -f $arg ]] || { printf "'%s' not a valid file\n" "$arg";return 1;}
    case "$arg" in
      *.tar.bz2) tar xjf "$arg";;
      *.tar.gz) tar xzf "$arg";;
      *.tar.xz|*.tar.zst|*.tar) tar xf "$arg";;
      *.bz2) bunzip2 "$arg";;
      *.gz) gunzip "$arg";;
      *.tbz2) tar xjf "$arg";;
      *.tgz) tar xzf "$arg";;
      *.zip) unzip "$arg";;
      *.Z) uncompress "$arg";;
      *.rar) rar x "$arg";;
      *) printf "'%s' cannot be extracted, assuming binary\n" "$arg";return 1;;
    esac
  }
  trap 'rm -rf "$TMP"' EXIT
  mkdir -p "$TMP"
  [[ -n $tag ]] || { PS3="> Select version: ";tag=$(choose $(gh api "repos/$repo/releases" -q ".[].tag_name"));}
  printf '[version] %s\n' "$tag"
  PS3="> Select file: "
  local filename=$(choose $(gh api "repos/$repo/releases" -q '.[]|select(.tag_name=="'"$tag"'")|.assets[].name'))
  printf '[filename] %s\n[*] Downloading...\n' "$filename"
  gh release download "$tag" --repo "$repo" --pattern "$filename" --dir "$TMP"
  (
    cd "$TMP"
    if [[ $filename == *.deb ]];then
      printf '[*] Installing debian package...\n'
      sudo apt install "./${filename}";exit 0
    fi
    printf '[*] Extracting...\n'
    local bin
    if extract "$filename";then
      PS3="> Select binary: "
      bin=$(choose $(find . -type f -not -path "*$filename"))
    else
      bin="$filename"
    fi
    local basename="${bin##*/}" name
    read -rp "> Choose a name (empty to leave: $basename): " name
    mkdir -p "$binpath"
    local target="$binpath/${name:-$basename}"
    mv "$bin" "$target";chmod +x "$target"
    printf 'Success!\nSaved in: %s\n' "$target"
  )
}
# ============================================================================
# MAINT
# ============================================================================
cmd_maint(){
  for g in gix git;do has "$g" && GIT="$g" && break;done
  [[ -n ${GIT:-} ]] || die "git/gix required"
  [[ -d .git ]] || die "Not a git repository"
  local DRY_RUN=false AUTO_YES=true VERBOSE=false MODE=both
  while [[ $# -gt 0 ]];do
    case "$1" in
      clean|update|both) MODE="$1";shift;;
      -d|--dry-run) DRY_RUN=true;shift;;
      -y|--yes) AUTO_YES=true;shift;;
      -v|--verbose) VERBOSE=true;shift;;
      -h|--help) usage;exit 0;;
      *) die "Unknown: $1";;
    esac
  done
  msg(){ printf '\033[0;96m==> %s\033[0m\n' "$1";}
  ok(){ printf '\033[0;92m%s\033[0m\n' "$1";}
  determine_trunk(){
    git branch --list master 2>/dev/null|grep -qF master && printf 'master' && return
    git branch --list main 2>/dev/null|grep -qF main && printf 'main' && return
    die "No trunk branch found"
  }
  update_repo(){
    msg "Updating repository..."
    local trunk=$(determine_trunk)
    if [[ $DRY_RUN == false ]];then
      git remote prune origin &>/dev/null||:
      git fetch --prune --no-tags origin||die "Fetch failed"
      git checkout "$trunk" &>/dev/null
      git pull --rebase origin "$trunk"||:
      ok "Updated"
    fi
  }
  clean_repo(){
    msg "Cleaning repository..."
    local trunk=$(determine_trunk) count=0
    if [[ $DRY_RUN == false ]];then
      git checkout "$trunk" &>/dev/null
      git fetch --prune||die "Fetch failed"
    fi
    while IFS= read -r branch;do
      [[ $branch == "$trunk" || -z $branch ]] && continue
      if [[ $AUTO_YES == true ]] || {
        printf 'Delete %s? [y/N] ' "$branch"
        read -r reply
        [[ ${reply,,} == y ]]
      };then
        [[ $DRY_RUN == false ]] && git branch -D "$branch" &>/dev/null && ((count++))
      fi
    done < <(git branch --merged "$trunk" --format='%(refname:short)')
    [[ $count -gt 0 ]] && ok "Deleted $count branches"||ok "No merged branches"
    if [[ $DRY_RUN == false ]];then
      git gc --aggressive --prune=now --quiet &>/dev/null||:
      git reflog expire --expire=30.days.ago --all &>/dev/null||:
      ok "Optimized"
    fi
  }
  case "$MODE" in
    clean) clean_repo;;
    update) update_repo;;
    both) update_repo;clean_repo;;
  esac
}
# ============================================================================
# MAIN
# ============================================================================
main(){
  local cmd="${1:-}"
  shift||:
  case "$cmd" in
    asset) cmd_asset "$@";;
    install) cmd_install "$@";;
    maint) cmd_maint "$@";;
    -h|--help|help|"") usage;;
    *) die "Unknown: $cmd";;
  esac
}
main "$@"
