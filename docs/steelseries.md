### [Steelseries setup](https://github.com/MiddleMan5/steelseries-linux)

```bash
paru -S --needed --noconfirm --skipreview base-devel hidapi evtest input-remapper-git
```

### [Wine setup](https://github.com/MiddleMan5/steelseries-linux#wine-setup)

```bash
wine reg add HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\WineBus /v Enable\ SDL /t Reg_Dword /d 0
cp /usr/share/fonts/liberation/LiberationSans-Bold.ttf ~/.wine/drive_c/windows/Fonts/arialbd.ttf
cp /usr/share/fonts/liberation/LiberationSans-Regular.ttf ~/.wine/drive_c/windows/Fonts/ariblk.ttf
```
