- https://wiki.archlinux.org/title/Gaming#Improving_performance
- https://linux-gaming.kwindu.eu/index.php/Main_Page

### General

```bash
PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 PROTON_HIDE_NVIDIA_GPU=0 LD_BIND_NOW=1 __GL_THREADED_OPTIMIZATIONS=1 %command%
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


### [Mouse overclocking](https://wiki.archlinux.org/title/Mouse_polling_rate#Polling_rate_not_changing)

```bash
paru -S evhz-git dkms wmo_oc-dkms
```

### Mimalloc

```bash
sudo pacman -S mimalloc
env LD_PRELOAD=/usr/lib/libmimalloc.so.2
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
