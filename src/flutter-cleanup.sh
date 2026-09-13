#!/usr/bin/env bash

set -Eeuo pipefail

log() { printf '[flutter-cleanup] %s\n' "$*"; }

log "Initiating cleanup of Flutter development environment"

# 1. Gracefully shutdown Android SDK Emulators (AVD)
if command -v adb >/dev/null 2>&1; then
    mapfile -t EMU_DEVICES < <(adb devices | grep emulator | cut -f1)
    for EMU in "${EMU_DEVICES[@]}"; do
        if [[ -n "$EMU" ]]; then
            adb -s "$EMU" emu kill >/dev/null 2>&1 || true
        fi
    done
    sleep 2 
fi

# 2. Force kill remaining qemu/emulator processes using -f to bypass 15-char limit
pkill -KILL -f '[e]mulator' >/dev/null 2>&1 || true
pkill -KILL -x qemu-system-x86_64 >/dev/null 2>&1 || true

# 3. Hard Kill Waydroid (LXC Container and UI)
if command -v waydroid >/dev/null 2>&1; then
    waydroid session stop >/dev/null 2>&1 || true
    if command -v systemctl >/dev/null 2>&1; then
        if (( EUID == 0 )); then
            systemctl stop waydroid-container >/dev/null 2>&1 || true
        elif command -v sudo >/dev/null 2>&1; then
            sudo systemctl stop waydroid-container || true
        fi
    fi
    
    pkill -KILL -f '[w]aydroid' >/dev/null 2>&1 || true
    pkill -KILL -f '[c]om\.android' >/dev/null 2>&1 || true
    pkill -KILL -f '[c]om\.google\.android' >/dev/null 2>&1 || true
fi

# 4. Stop Genymotion Virtual Machines
if command -v gmtool >/dev/null 2>&1 || [[ -x "/opt/genymobile/genymotion/gmtool" ]]; then
    GMTOOL_BIN="gmtool"
    if ! command -v gmtool >/dev/null 2>&1; then
        GMTOOL_BIN="/opt/genymobile/genymotion/gmtool"
    fi
    
    mapfile -t RUNNING_VMS < <("$GMTOOL_BIN" admin list | grep "On" | grep -E "\|.*\|.*\|.*\|" | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')
    
    if (( ${#RUNNING_VMS[@]} > 0 )); then
        for VM in "${RUNNING_VMS[@]}"; do
            "$GMTOOL_BIN" admin stop "$VM" >/dev/null 2>&1 || true
        done
    fi
    
    pkill -KILL -f '[g]enymotion/player' >/dev/null 2>&1 || true
fi

# 5. Clean up Android Studio / Gradle
if command -v gradle >/dev/null 2>&1; then
    gradle --stop >/dev/null 2>&1 || true
elif [[ -d "$HOME/.gradle/daemon" ]]; then
    pkill -KILL -f '[g]radle' >/dev/null 2>&1 || true
fi

pkill -KILL -f '[a]ndroid-studio' >/dev/null 2>&1 || true
pkill -KILL -f '[k]otlin.daemon' >/dev/null 2>&1 || true

# 6. Kill ADB Server
if command -v adb >/dev/null 2>&1; then
    adb kill-server >/dev/null 2>&1 || true
fi

log "Cleanup complete"