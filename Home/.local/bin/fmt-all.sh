#!/usr/bin/env bash
set -euo pipefail;shopt -s nullglob globstar;IFS=$'\n\t';LC_ALL=C;LANG=C
has(){ command -v -- "$1" &>/dev/null;}
has image-optimizer && image-optimizer -r --png-optimization-level max --zopfli-iterations 100 -i .
has mdfmt && mdfmt . --width 120 -w
has tombi && tombi format
has yamlfmt && yamlfmt -continue_on_error "*.yaml"
has shellharden && { shellharden --replace ./*.sh||:; shellharden --replace ./*.bash||:; shellharden --replace ./*.zsh||:;}
has biome && biome check --fix --unsafe --skip-parse-errors --no-errors-on-unmatched --html-formatter-line-width=120 --css-formatter-line-width=120 --json-formatter-line-width=120 --use-editorconfig=true --indent-style=space --format-with-errors=true --files-ignore-unknown=true --vcs-use-ignore-file=false .
has ruff && ruff format --line-length 120
has gh && { gh tidy; gh poi;}
git gc --aggressive --prune=now; git repack -ab; git maintenance run
git add -A; git commit -m "Format & Lint" && git push
