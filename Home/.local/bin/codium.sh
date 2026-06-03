#!/usr/bin/bash

export VSCODE_PORTABLE=/home/"user"/.local/vscodium && mkdir -p "$VSCODE_PORTABLE"
export VSCODE_CLI_DATA_DIR=/home/"user"/.local/vscodium/cli && mkdir -p "$VSCODE_CLI_DATA_DIR"

IFS=$'{\n}'
/usr/bin/codium $@
