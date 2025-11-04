#!/usr/bin/env bash
# SSH key generation and deployment script
email=""
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/pi_ed25519 -C "${email}"
target=""
ssh-copy-id -i ~/.ssh/pi_ed25519.pub dietpi@192.168.178.86
