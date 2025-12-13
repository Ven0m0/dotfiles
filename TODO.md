# Bash

```bash
# Enable right prompt when you figure out what to add there
# RIGHT_PROMPT="\n\$(tput sc; rightprompt; tput rc)"

echo "${PATH//:/$'\n'}"
```

- https://www.jetify.com/devbox
- https://github.com/ChrisTitusTech/linutil/tree/main/core/tabs

# Misc

### Github actions

- https://github.com/marketplace/actions/auto-update
- https://github.com/marketplace/actions/repo-file-sync-action
- https://github.com/marketplace/actions/file-sync

### Shell

- https://github.com/gmou3/fzf-preview
- https://github.com/BartSte/fzf-help
- https://github.com/beauwilliams/Dotfiles

### Adblock

- https://hermit.chimbori.com/config/content-blockers/v2/PaidContentLinks.txt
- https://github.com/hoshsadiq/adblock-nocoin-list/master/hosts.txt
- https://hermit.chimbori.com/config/content-blockers/v2/UserSuggested.txt
- https://github.com/MetaMask/eth-phishing-detect/master/src/hosts.txt
- https://urlhaus.abuse.ch/downloads/hostfile

### web dev

- netlify.com
- surge.sh
- render.com

### Fix wine steelseries gg

```bash
wine reg add HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\WineBus /v Enable\ SDL /t Reg_Dword /d 0
# Change these paths to your respective files.
cp /usr/share/fonts/TTF/arialbd.ttf ~/.wine/drive_c/windows/Fonts/arialbd.ttf
cp /usr/share/fonts/TTF/ariblk.ttf ~/.wine/drive_c/windows/Fonts/ariblk.ttf
```
