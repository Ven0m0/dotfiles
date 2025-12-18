#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
has git || exit 1
git add -A
# Find all .git folders except in the main folder and delete them
find "$PWD" -type d -name .git -not -path "${PWD}/.git" -exec rm -rf {} +
has image-optimizer && image-optimizer -r --png-optimization-level max --zopfli-iterations 100 -i "$PWD"
has mdfmt && mdfmt --width 88 -w "$PWD"
has tombi && tombi format "$PWD"
has yamlfmt && { yamlfmt -continue_on_error "*.yaml"; yamlfmt -continue_on_error "*.yml"; }
has shellharden && { shellharden --replace ./*.sh || :; shellharden --replace ./*.bash || :; shellharden --replace ./*.zsh || :; }
has biome && biome check --fix --unsafe --skip-parse-errors --no-errors-on-unmatched --html-formatter-line-width=120 --css-formatter-line-width=120 --json-formatter-line-width=120 \
  --use-editorconfig=true --indent-style=space --format-with-errors=true --files-ignore-unknown=true --vcs-use-ignore-file=false "$PWD"
if has ruff; then 
  ruff format --line-length 120 --target-version py311 "$PWD"
fi
has gh && { gh tidy; gh poi; }
git maintenance run --quiet --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune &>/dev/null || :
git -c protocol.file.allow=always submodule update --init --remote --rebase --depth 1 --filter=blob:none 
git add -A
git commit -q -m "Format & Lint" &>/dev/null && git push --recurse-submodules=on-demand --prune
