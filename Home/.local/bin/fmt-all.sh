#!/usr/bin/env bash
set -euo pipefail; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C

has(){ command -v -- "$1" &>/dev/null; }

if has image-optimizer; then
  image-optimizer -r --png-optimization-level max --zopfli-iterations 100 -i .
fi
if has mdfmt; then
  mdfmt . --width 120 -w
fi
if has tombi; then
  tombi format
fi
if has yamlfmt; then
  yamlfmt -continue_on_error "*.yaml"
fi
if has shellharden; then
  # TODO: which one?
  shellharden --replace *.sh || :
  shellharden --replace *.bash || :
  shellharden --replace *.zsh || :
  #shellharden --replace **/*.sh || :
  #shellharden --replace **/*.bash || :
  #shellharden --replace **/*.zsh || :
fi
if has biome; then
  biome check --fix --unsafe --skip-parse-errors --no-errors-on-unmatched --html-formatter-line-width=120 --css-formatter-line-width=120 \
    --json-formatter-line-width=120 --use-editorconfig=true --indent-style=space --format-with-errors=true --files-ignore-unknown=true \
    --vcs-use-ignore-file=false .
fi
if has gh; then
   gh tidy; gh poi
fi
git gc --aggressive --prune=now
git repack -ab
git maintenance run
git add -A; git commit -m "Format & Lint" && git push
