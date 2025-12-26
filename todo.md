dbus-update-activation-environment --systemd --all
dbus-cleanup-sockets

export QPDF_ZOPFLI=silent
qpdf --compress-streams --remove-restrictions --remove-unreferenced-resources  --remove-metadata --no-warn --progress \
  --compress-streams=y --decode-level=generalized --recompress-flate --compression-level=9 --optimize-images --jpeg-quality 75 --object-streams=generate --linearize


# Clean steam

~/.steam/root/steamapps/shadercache
~/.steam/root/steamapps/temp
~/.steam/root/appcache/httpcache
~/.steam/root/appcache/librarycache
~/.steam/root/logs


duperemove -r -d "/run/media/lucy/storage"
beesd "/run/media/lucy/storage"

adb shell pm compile -a --full -r cmdline -p PRIORITY_INTERACTIVE_FAST --force-merge-profile -m speed-profile
