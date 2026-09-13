#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/flutter-dev-common.sh"

# Force Qt to use X11/XWayland to avoid Wayland plugin missing crash
export QT_QPA_PLATFORM=xcb
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"

EMULATOR_BIN="$ANDROID_HOME/emulator/emulator"

[[ -x "$EMULATOR_BIN" ]] || die "Emulator binary not found at $EMULATOR_BIN"

mapfile -t AVDS < <("$EMULATOR_BIN" -list-avds)

(( ${#AVDS[@]} > 0 )) || die "No Android Virtual Devices (AVD) found"

SELECTED_AVD="${AVDS[0]}"
log "Starting emulator: $SELECTED_AVD"

# Launch emulator in background
"$EMULATOR_BIN" -avd "$SELECTED_AVD" >/dev/null 2>&1 &
EMULATOR_PID=$!

log "Waiting for Android emulator to finish booting..."
require_command adb
wait_for_android_boot "" 120

open_project "${1:-.}"
log "Emulator is ready (pid $EMULATOR_PID)"
