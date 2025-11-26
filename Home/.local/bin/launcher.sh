#!/usr/bin/env bash
# Select launcher based on availability
if command -v bemenu &>/dev/null; then
  # -i: insensitive, -l: lines (vertical), -p: prompt
  _menu() { bemenu -i -l 10 -p "$1" --tf "$COLOR_ACCENT" --hf "$COLOR_HIGHLIGHT"; }
elif command -v rofi &>/dev/null; then
  # -dmenu: pipe mode, -i: insensitive, -p: prompt
  _menu() { rofi -dmenu -i -p "$1"; }
else
  printf "No menu tool found.\n" >&2; exit 1
fi
