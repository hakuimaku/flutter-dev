#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/flutter-dev-common.sh"

require_command adb
require_command waydroid

log "Starting Waydroid session"
waydroid session start >/dev/null 2>&1 &

log "Waiting for Waydroid to assign an IP"

WAYDROID_IP=""
MAX_RETRIES=30

for (( retry = 0; retry < MAX_RETRIES; retry++ )); do
    sleep 1
    WAYDROID_IP=$(waydroid status 2>/dev/null | sed -n 's/^[[:space:]]*IP:[[:space:]]*\([0-9.]*\)[[:space:]]*$/\1/p' | head -n 1)
    [[ -n "$WAYDROID_IP" ]] && break
done

[[ -n "$WAYDROID_IP" ]] || die "Waydroid IP not found after ${MAX_RETRIES}s"

WAYDROID_SERIAL="$WAYDROID_IP:5555"
log "Connecting ADB to Waydroid at $WAYDROID_SERIAL"

adb connect "$WAYDROID_SERIAL" >/dev/null
wait_for_android_boot "$WAYDROID_SERIAL" 60

log "Opening Waydroid UI"
waydroid show-full-ui >/dev/null 2>&1 &
open_project "${1:-.}"
log "Waydroid is ready; you can now run 'flutter run'"
