#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail; shopt -s nullglob globstar
export LC_ALL=C; IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }
has image-optimizer && image-optimizer -r --png-optimization-level max --zopfli-iterations 100 -i .
has mdfmt && mdfmt . --width 120 -w
has tombi && tombi format
has yamlfmt && yamlfmt -continue_on_error "*.yaml"
has shellharden && { shellharden --replace ./*.sh || :; shellharden --replace ./*.bash || :; shellharden --replace ./*.zsh || :; }
has biome && biome check --fix --unsafe --skip-parse-errors --no-errors-on-unmatched --html-formatter-line-width=120 --css-formatter-line-width=120 --json-formatter-line-width=120 --use-editorconfig=true --indent-style=space --format-with-errors=true --files-ignore-unknown=true --vcs-use-ignore-file=false .
if has uv; then 
  has ruff && ruff format --line-length 120 --target-version py311 "${PWD:-.}"
  has black && uv tool run black -l 120 -t py313 "${PWD:-.}" 
fi
has gh && { gh tidy; gh poi; }
git maintenance run --quiet --task=prefetch --task=gc --task=loose-objects --task=incremental-repack --task=pack-refs --task=reflog-expire --task=rerere-gc --task=worktree-prune &>/dev/null || :
git add -A && git commit -q -m "Format & Lint" &>/dev/null && git push --recurse-submodules=on-demand --prune
