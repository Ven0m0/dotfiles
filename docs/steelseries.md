### [Steelseries setup](https://github.com/MiddleMan5/steelseries-linux)

```bash
paru -S --needed --noconfirm --skipreview base-devel hidapi evtest input-remapper-git
```

### [Wine setup](https://github.com/MiddleMan5/steelseries-linux#wine-setup)

```bash
sudo pacman -S --noconfirm --needed wine-mono winetricks cabextract
export WINEPREFIX="$HOME/.wine" WINEARCH=win64
wine reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebus" /v "Enable SDL" /t REG_DWORD /d 0
wine reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebus" /v "DisableHidraw" /t REG_DWORD /d 0
cp "/usr/share/fonts/liberation/LiberationSans-Bold.ttf" "$WINEPREFIX/drive_c/windows/Fonts/arialbd.ttf"
cp "/usr/share/fonts/liberation/LiberationSans-Regular.ttf" "$WINEPREFIX/drive_c/windows/Fonts/ariblk.ttf"
winetricks -q dotnet48 vcrun2019 corefonts
GDK_BACKEND=x11 wine "$WINEPREFIX/drive_c/Program Files/SteelSeries/SteelSeries GG/SteelSeriesGG.exe"
ln -s -f /usr/share/dxvk/x32/*.dll ~/.wine/drive_c/windows/syswow64
ln -s -f /usr/share/dxvk/x64/*.dll ~/.wine/drive_c/windows/system32
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d8 /d native,builtin /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d9 /d native,builtin /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d10core /d native,builtin /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d11 /d native,builtin /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v dxgi /d native,builtin /f
ln -s /usr/share/dxvk ~/.local/share/lutris/runtime/dxvk/dxvk-git
ln -s -f /usr/share/vkd3d-proton/x86/*.dll ~/.wine/drive_c/windows/syswow64
ln -s -f /usr/share/vkd3d-proton/x64/*.dll ~/.wine/drive_c/windows/system32
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d12 /d native,builtin /f
wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v d3d12core /d native,builtin /f
ln -s /usr/share/vkd3d-proton ~/.local/share/lutris/runtime/vkd3d/vkd3d-proton-git
```


<https://gitlab.winehq.org/wine/wine/-/wikis/Useful-Registry-Keys>


Misc WINE

```bash
wine reg ADD 'HKEY_CURRENT_USER\Software\Wine\X11 Driver' /v UseTakeFocus /d 'N' /f
wine reg add "HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f
```

add as launch arguments: `--single-process --disable-gpu --disable-gpu-compositing --in-process-gpu`
