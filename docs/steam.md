- https://wiki.archlinux.org/title/Gaming#Improving_performance
- https://linux-gaming.kwindu.eu/index.php/Main_Page

### General

```bash
PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 LD_BIND_NOW=1 PULSE_LATENCY_MSEC=60 %command%
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
VKD3D_CONFIG=dxr,dxr11
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
```
### Prevent crashdumps, keep login

```bash
chattr +i ~/.steam/registry.vdf
ln -s /dev/null /tmp/dumps
mkdir /tmp/dumps
chmod 600 /tmp/dumps
```
## Games:

- Celeste: `SDL_VIDEODRIVER=wayland %command%`
- Hollow Knight: `-force-vulkan %command%`
- Haste: `-force-vulkan %command%`
- ARC Raiders: `mangohud __GL__THREADED_OPTIMIZATIONS=1 PROTON_LOCAL_SHADER_CACHE=1 DXVK_ASYNC=1 PROTON_NVIDIA_LIBS=1 PROTON_USE_EAC_LINUX=1 PROTON_ENABLE_NVAPI=1 PROTON_DLSS_UPGRADE=1 PROTON_ENABLE_WAYLAND=1 PROTON_FSR4_UPGRADE=1 PROTON_USE_NTSYNC=1 DXVK_CONFIG="dxgi.syncInterval=0 gamemoderun mangohud %command% -novid -dx12 -fullscreen -useallavailablecores`
  > - `sudo sysctl -w vm.max_map_count=2147483642vm.max_map_count=2147483642`
  > - Set mangohud (mangojuice) VSYNC > VULKAN config to OFF for IMMEDIATE frame presentation.
- Terraria: `FNA_GRAPHICS_BACKEND=Vulkan SDL_AUDIODRIVER=pipewire %command%`
- The Witcher 3: `PROTON_ENABLE_NVAPI=1 PROTON_DXVK_GPLASYNC=1 VKD3D_CONFIG=dxr,dxr11 %command% -novid`
