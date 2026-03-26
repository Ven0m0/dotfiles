#!/usr/bin/env bash
set -euo pipefail
xargs -n 1 code --install-extension < extensions.txt
