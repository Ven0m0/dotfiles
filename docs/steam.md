- https://wiki.archlinux.org/title/Gaming#Improving_performance
- https://linux-gaming.kwindu.eu/index.php/Main_Page

### General

```bash
PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 LD_BIND_NOW=1 PULSE_LATENCY_MSEC=30 %command%
```

`/etc/environment`

```bash
WINEESYNC=1
WINEFSYNC=1
WINEDLLOVERRIDES=mscoree=d;mshtml=d
```

### offline:

```bash
DXVK_ASYNC=1
```

### latency:

```bash
echo madvise | sudo tee >/sys/kernel/mm/transparent_hugepage/enabled
echo advise | sudo tee >/sys/kernel/mm/transparent_hugepage/shmem_enabled
echo 0 | sudo tee /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
```

### misc:

```bash
VKD3D_CONFIG=dxr
```

### Kernel cmdline:

```
tsc=reliable clocksource=tsc
```

### Mouse

```bash
paru -S evhz-git
```

### Steam launch

```bash
steam -compat-force-slr off 
```

### Wine fonts

```bash
cd ${WINEPREFIX:-~/.wine}/drive_c/windows/Fonts && for i in /usr/share/fonts/**/*.{ttf,otf}; do ln -s "$i"; done
export FREETYPE_PROPERTIES="truetype:interpreter-version=35"
```

### Force keep password steam

```bash
chattr +i ~/.steam/registry.vdf
```

### Prevent crashdumps

```bash
ln -s /dev/null /tmp/dumps
mkdir /tmp/dumps
chmod 600 /tmp/dumps
```
