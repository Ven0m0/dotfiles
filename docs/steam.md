- https://wiki.archlinux.org/title/Gaming#Improving_performance
- https://linux-gaming.kwindu.eu/index.php/Main_Page
- https://www.protondb.com
- https://lutris.net
- https://github.com/ValveSoftware/Proton
- https://github.com/HansKristian-Work/vkd3d-proton
- https://github.com/Etaash-mathamsetty/Proton/blob/em-10/docs/EM-ADDITIONS.md
- https://github.com/Etaash-mathamsetty/Proton/blob/em-10/docs/FSR4.md
- https://github.com/pythonlover02/DXVK-Sarek#shader-compilation
- https://github.com/netborg-afps/dxvk-low-latency#dxvk-low-latency

### General

-> For arch:

```bash
parru -S dxvk-async-git dxvk-nvapi-vkreflex-layer vkd3d-proton-git vkd3d proton-cachyos-slr bottles protontricks
```

Gamescope: `gamescope -f --force-grab-cursor -w 1920 -h 1080 -- %command%`

```bash
PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 LD_BIND_NOW=1 PULSE_LATENCY_MSEC=30 %command%
```
`/etc/environment`

```bash
WINEESYNC=1
WINEFSYNC=1
WINEDLLOVERRIDES=mscoree=d;mshtml=d
PROTON_USE_WOW64=1
```
### offline:

```bash
DXVK_ASYNC=1 PROTON_DXVK_SAREK=1
```
### latency:

```bash
echo madvise | sudo tee >/sys/kernel/mm/transparent_hugepage/enabled
```
### misc:

```bash
VKD3D_CONFIG=dxr12,dxr,force_static_cbv,force_static_cbv
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
Wine regedit

```reg
[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"Renderer"="vulkan"
"MultisampleTextures"=dword:00000000
"Multisampling"="disabled"
"CSMT"="enabled"
"StrictDrawOrdering"="disabled"
```

## Games:

- Celeste: `SDL_VIDEODRIVER=wayland %command%`
- Hollow Knight: `-force-vulkan %command%`
- Haste: `-force-vulkan %command%`
- ARC Raiders: `__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 __GL_SYNC_TO_VBLANK=0 __GL_MaxFramesAllowed=1 __GLX_VENDOR_LIBRARY_NAME=nvidia PROTON_LOCAL_SHADER_CACHE=1 PROTON_DLSS_UPGRADE=1 PROTON_ENABLE_WAYLAND=1 PROTON_USE_NTSYNC=1 PROTON_USE_VKD3D=1 DXVK_ASYNC=1 DXVK_STATE_CACHE=1 PROTON_LOCAL_SHADER_CACHE=1 PROTON_ENABLE_NVAPI=1 dlss-swapper game-performance %command% -dx12`
  > - `sudo sysctl -w vm.max_map_count=2147483642` and LD_PRELOAD="" (crash fix)
  > - Set mangohud (mangojuice) VSYNC > VULKAN config to OFF for IMMEDIATE frame presentation
  > - Add kernel parameter: vsyscall=emulate
- Terraria: `FNA_GRAPHICS_BACKEND=Vulkan SDL_AUDIODRIVER=pipewire %command%`
- The Witcher 3: `PROTON_ENABLE_NVAPI=1 PROTON_DXVK_GPLASYNC=1 VKD3D_CONFIG=dxr,dxr11 %command% -novid`


`mangohud __GL__THREADED_OPTIMIZATIONS=1 PULSE_LATENCY_MSEC=30 DXVK_STATE_CACHE=1 PROTON_LOCAL_SHADER_CACHE=1 PROTON_DXVK_SAREK=1 DXVK_ASYNC=1 DXVK_ENABLE_NVAPI=1 PROTON_NVIDIA_NVOPTIX=1 PROTON_NVIDIA_LIBS_NO_32BIT=1 PROTON_USE_EAC_LINUX=1 PROTON_ENABLE_NVAPI=1 PROTON_ENABLE_NGX_UPDATER=1 PROTON_DLSS_UPGRADE=1 PROTON_ENABLE_WAYLAND=1 PROTON_FSR4_UPGRADE=1 PROTON_USE_NTSYNC=1 DXVK_CONFIG="dxgi.syncInterval=0 VKD3D_CONFIG=dxr12,dxr,upload_hvv LD_PRELOAD="" XMODIFIERS="" mangohud dlss-swapper game-performance %command% -dx12 -full-screen -useallavailablecores -high`
