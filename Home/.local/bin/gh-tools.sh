#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t'
export LC_ALL=C LANG=C

has(){ command -v -- "$1" &>/dev/null;}
die(){ printf 'ERROR: %s\n' "$*" >&2;exit 1;}
need(){ has "$1" || die "Required: $1";}
if has jaq;then JQ=jaq;elif has jq;then JQ=jq;else die "jq/jaq required";fi

usage(){
  cat <<'EOF'
gh-tools - GitHub utilities
USAGE: gh-tools COMMAND [ARGS...]
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

cmd_asset(){
  need curl
  local release="" output_opt=(-O) curl_args=(-fsSL) TMP
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
  local repo="$1" substring="$2"
  TMP=$(mktemp);trap 'rm -f "$TMP"' EXIT
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

cmd_install(){
  need gh
  local tag="" binpath="${GH_BINPATH:-$HOME/.local/bin}" TMP="/tmp/.gh-install" opt filename bin basename name target
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
  trap 'rm -rf "$TMP"' EXIT;mkdir -p "$TMP"
  [[ -n $tag ]] || {
    if has fzf;then
      tag=$(gh api "repos/$repo/releases" -q ".[].tag_name"|fzf --height 10 --prompt "> Select version: " -1)
    else
      PS3="> Select version: "
      select tag in $(gh api "repos/$repo/releases" -q ".[].tag_name");do break;done
    fi
  }
  printf '[version] %s\n' "$tag"
  if has fzf;then
    filename=$(gh api "repos/$repo/releases" -q '.[]|select(.tag_name=="'"$tag"'")|.assets[].name'|fzf --height 10 --prompt "> Select file: " -1)
  else
    PS3="> Select file: "
    select filename in $(gh api "repos/$repo/releases" -q '.[]|select(.tag_name=="'"$tag"'")|.assets[].name');do break;done
  fi
  printf '[filename] %s\n[*] Downloading...\n' "$filename"
  gh release download "$tag" --repo "$repo" --pattern "$filename" --dir "$TMP"
  (
    cd "$TMP"
    if [[ $filename == *.deb ]];then
      printf '[*] Installing debian package...\n'
      sudo apt install "./${filename}";exit 0
    fi
    printf '[*] Extracting...\n'
    if [[ -f $filename ]];then
      case "$filename" in
        *.tar.bz2|*.tbz2) tar xjf "$filename";;
        *.tar.gz|*.tgz) tar xzf "$filename";;
        *.tar.xz|*.tar.zst|*.tar) tar xf "$filename";;
        *.bz2) bunzip2 "$filename";;
        *.gz) gunzip "$filename";;
        *.zip) unzip "$filename";;
        *.Z) uncompress "$filename";;
        *.rar) rar x "$filename";;
        *) printf "'%s' cannot be extracted, assuming binary\n" "$filename";;
      esac
    fi
    if has fzf;then
      bin=$(find . -type f -not -path "*$filename"|fzf --height 10 --prompt "> Select binary: " -1||printf '%s' "$filename")
    else
      PS3="> Select binary: "
      select bin in $(find . -type f -not -path "*$filename");do break;done
      [[ -z $bin ]] && bin="$filename"
    fi
    basename="${bin##*/}"
    read -rp "> Choose a name (empty to leave: $basename): " name
    mkdir -p "$binpath"
    target="$binpath/${name:-$basename}"
    mv "$bin" "$target";chmod +x "$target"
    printf 'Success!\nSaved in: %s\n' "$target"
  )
}

cmd_maint(){
  local GIT
  for g in gix git;do has "$g" && GIT="$g" && break;done
  [[ -n ${GIT:-} ]] || die "git/gix required"
  [[ -d .git ]] || die "Not a git repository"
  local DRY_RUN=false AUTO_YES=true VERBOSE=false MODE=both trunk count=0 branch reply
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
  trunk=$(git branch --list master main 2>/dev/null|grep -oE '(master|main)'|head -n1)
  [[ -n $trunk ]] || die "No trunk branch found"
  if [[ $MODE == update || $MODE == both ]];then
    printf '\033[0;96m==> Updating repository...\033[0m\n'
    if [[ $DRY_RUN == false ]];then
      git remote prune origin &>/dev/null||:
      git fetch --prune --no-tags origin||die "Fetch failed"
      git checkout "$trunk" &>/dev/null
      git pull --recurse-submodules=on-demand -r origin "$trunk"||:
      printf '\033[0;92mUpdated\033[0m\n'
    fi
  fi
  if [[ $MODE == clean || $MODE == both ]];then
    printf '\033[0;96m==> Cleaning repository...\033[0m\n'
    if [[ $DRY_RUN == false ]];then
      git checkout "$trunk" &>/dev/null
      git fetch --prune||die "Fetch failed"
    fi
    while IFS= read -r branch;do
      [[ $branch == "$trunk" || -z $branch ]] && continue
      if [[ $AUTO_YES == true ]] || {
        printf 'Delete %s? [y/N] ' "$branch"
        read -r reply;[[ ${reply,,} == y ]]
      };then
        [[ $DRY_RUN == false ]] && git branch -D "$branch" &>/dev/null && ((count++))
      fi
    done < <(git branch --merged "$trunk" --format='%(refname:short)')
    [[ $count -gt 0 ]] && printf '\033[0;92mDeleted %d branches\033[0m\n' "$count" || printf '\033[0;92mNo merged branches\033[0m\n'
    if [[ $DRY_RUN == false ]];then
      git maintenance run --quiet --task=prefetch --task=gc --task=loose-objects --task=incremental-repack \
        --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune --task=commit-graph &>/dev/null||:
      printf '\033[0;92mOptimized\033[0m\n'
    fi
  fi
}
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
