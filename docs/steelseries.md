### [Steelseries setup](https://github.com/MiddleMan5/steelseries-linux)

```bash
paru -S --needed --noconfirm --skipreview base-devel hidapi evtest input-remapper-git
```

### [Wine setup](https://github.com/MiddleMan5/steelseries-linux#wine-setup)

```bash
export WINEPREFIX="$HOME/.wine" GDK_BACKEND=x11
wine reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebus" /v "Enable SDL" /t REG_DWORD /d 0
wine reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebus" /v "DisableHidraw" /t REG_DWORD /d 0
cp "/usr/share/fonts/liberation/LiberationSans-Bold.ttf" "$WINEPREFIX/drive_c/windows/Fonts/arialbd.ttf"
cp "/usr/share/fonts/liberation/LiberationSans-Regular.ttf" "$WINEPREFIX/drive_c/windows/Fonts/ariblk.ttf"
winetricks -q dotnet48 vcrun2019 corefonts
```

or clean wine:

```bash
export WINEPREFIX="$HOME/.wine-gg"
wineboot -u
winetricks -q dotnet48 vcrun2019 corefonts
wine reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebus" /v "Enable SDL" /t REG_DWORD /d 0
cp "/usr/share/fonts/liberation/LiberationSans-Bold.ttf" "$WINEPREFIX/drive_c/windows/Fonts/arialbd.ttf"
cp "/usr/share/fonts/liberation/LiberationSans-Regular.ttf" "$WINEPREFIX/drive_c/windows/Fonts/ariblk.ttf"
winecfg
wine "$WINEPREFIX/drive_c/Program Files/SteelSeries/SteelSeries GG/SteelSeriesGG.exe"
```
