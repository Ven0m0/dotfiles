# shellcheck shell=sh
# Disable Mozilla's ASan Crash Reporter
## https://searchfox.org/mozilla-central/rev/a1f4cb9f/toolkit/xre/nsEmbedFunctions.cpp#261
## https://firefox-source-docs.mozilla.org/tools/sanitizer/asan_nightly.html
## https://github.com/choller/firefox-asan-reporter
export MOZ_DISABLE_ASAN_REPORTER=1
# Disable Mozilla's Crash Reporter
## https://firefox-source-docs.mozilla.org/toolkit/crashreporter/crashreporter/index.html#user-specified-environment-variables
export MOZ_CRASHREPORTER=0 MOZ_TELEMETRY_REPORTING=0 MOZ_SERVICES_HEALTHREPORT=0 MOZ_DATA_REPORTING=0
export MOZ_CRASHREPORTER_DISABLE=1
export MOZ_CRASHREPORTER_NO_REPORT=1
export MOZ_CRASHREPORTER_URL="data;"
# Disable SSLKEYLOGGING
## https://bugzilla.mozilla.org/show_bug.cgi?id=1183318
## https://bugzilla.mozilla.org/show_bug.cgi?id=1915224
export SSLKEYLOGFILE=""
# Enable Wayland
## Credit to Rasmus: https://askubuntu.com/users/13884/rasmus
## https://askubuntu.com/questions/1456684/how-to-initialize-firefox-on-wayland-always-by-default
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
  export MOZ_ENABLE_WAYLAND=1 MOZ_ENABLE_XINPUT2=1 MOZ_DBUS_REMOTE=1 MOZ_DISABLE_RDD_SANDBOX=1
fi
