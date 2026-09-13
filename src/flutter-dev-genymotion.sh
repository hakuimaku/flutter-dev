#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/flutter-dev-common.sh"

require_command adb

# 1. Check if gmtool binary exists
if ! command -v gmtool &> /dev/null; then
    if [[ -x "/opt/genymobile/genymotion/gmtool" ]]; then
        GMTOOL_BIN="/opt/genymobile/genymotion/gmtool"
    else
        echo "Error: 'gmtool' command not found. Please ensure Genymotion is installed properly."
        exit 1
    fi
else
    GMTOOL_BIN="gmtool"
fi

# 2. Get available Genymotion virtual machines
mapfile -t VMS < <("$GMTOOL_BIN" admin list | awk -F '|' 'NR > 2 {gsub(/^[ \t]+|[ \t]+$/, "", $3); if ($3 != "") print $3}')

(( ${#VMS[@]} > 0 )) || die "No Genymotion virtual devices found"

# 3. Select VM automatically if only one exists, or prompt user
SELECTED_VM=""

if [ ${#VMS[@]} -eq 1 ]; then
    SELECTED_VM="${VMS[0]}"
    log "Found 1 VM: $SELECTED_VM"
else
    log "Available Genymotion virtual devices:"
    for i in "${!VMS[@]}"; do
        printf "  [%d] %s\n" "$((i+1))" "${VMS[$i]}"
    done

    read -rp "Select a VM to launch (1-${#VMS[@]}): " CHOICE
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#VMS[@]}" ]; then
        SELECTED_VM="${VMS[$((CHOICE-1))]}"
    else
        die "Invalid VM selection"
    fi
fi

# 4. Check VM status and launch if not already running
VM_STATUS=$("$GMTOOL_BIN" admin list | awk -F '|' -v vm="$SELECTED_VM" '$0 ~ vm {gsub(/^[ \t]+|[ \t]+$/, "", $5); print $5; exit}')

if [ "$VM_STATUS" = "On" ]; then
    log "Virtual machine '$SELECTED_VM' is already running"
else
    log "Starting virtual machine: $SELECTED_VM"
    "$GMTOOL_BIN" admin start "$SELECTED_VM" >/dev/null 2>&1 &
fi

log "Waiting for Genymotion to finish booting"
wait_for_android_boot "" 120
open_project "${1:-.}"
log "Genymotion device is ready"
