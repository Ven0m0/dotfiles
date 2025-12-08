# Bash

```bash
# Enable right prompt when you figure out what to add there
# RIGHT_PROMPT="\n\$(tput sc; rightprompt; tput rc)"

echo "${PATH//:/$'\n'}"
```


- https://www.jetify.com/devbox
- https://github.com/ChrisTitusTech/linutil/tree/main/core/tabs
- https://github.com/spack/spack


# Misc

### Github actions
- https://github.com/marketplace/actions/auto-update
- https://github.com/marketplace/actions/cache-apt-packages
- https://github.com/marketplace/actions/repo-file-sync-action
- https://github.com/marketplace/actions/file-sync
- https://github.com/marketplace/actions/update-git-submodules
- https://github.com/marketplace/actions/submodules-alternative

### Shell
- https://github.com/gmou3/fzf-preview
- https://github.com/BartSte/fzf-help
- https://github.com/beauwilliams/Dotfiles
- https://crates.io/crates/dedups

- https://github.com/PatrickAlex2019/ApkEditor


### Chromium
- https://github.com/gonzazoid/Ultimatum
- https://github.com/Alex313031/Thorium
- https://github.com/uazo/cromite
- https://github.com/brave/brave-browser

### Firefox: 
- https://github.com/duckduckgo/Android
- https://github.com/lumiknit/ff-android-patches
- https://github.com/GoodyOG/Iceraven-OLED
- https://github.com/fork-maintainers/iceraven-browser
- https://github.com/thunderbird/thunderbird-android

- https://github.com/FirefoxUniverse/FirefoxTweaksVN/tree/main
- https://github.com/ChinaGodMan/UserScripts

- https://github.com/Konloch/bytecode-viewer
- https://github.com/Zenlua/Tool-Tree

- https://github.com/charles2gan/GDA-android-reversing-Tool

- https://greasyfork.org/en/scripts/541871-amazon-page-smoother/code

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
