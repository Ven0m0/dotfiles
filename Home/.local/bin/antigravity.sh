#!/bin/bash
# From https://gist.github.com/w568w/0999f61e9a646feac3f5a46aaa17e1d1
readonly UNIT_NAME="antigravity-$(date +%s)"
readonly APP_BIN="/usr/bin/antigravity --verbose"
readonly TRIGGER="Lifecycle#onWillShutdown - end 'antigravityAnalytics'"

echo "[*] Start as: $UNIT_NAME"

systemd-run --user \
    --scope \
    --unit="$UNIT_NAME" \
    --property=KillMode=control-group \
    /bin/bash -c "exec prlimit --core=0 $APP_BIN 2>&1 | systemd-cat --identifier=$UNIT_NAME" &

journalctl --user --identifier="$UNIT_NAME" --follow | \
    grep --line-buffered --max-count=1 "$TRIGGER" && \
    systemctl --user kill --signal=SIGKILL "$UNIT_NAME.scope"

echo "[*] Remaining processes are killed."
