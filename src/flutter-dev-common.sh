#!/usr/bin/env bash

log() {
	printf '[flutter-dev] %s\n' "$*"
}

die() {
	printf '[flutter-dev] error: %s\n' "$*" >&2
	exit 1
}

require_command() {
	local command_name="$1"

	command -v "$command_name" >/dev/null 2>&1 || die "Required command not found: $command_name"
}

wait_for_android_boot() {
	local serial="${1:-}"
	local timeout_seconds="${2:-120}"
	local adb_args=()
	local deadline
	local boot_completed
	local device_state

	[[ "$timeout_seconds" =~ ^[0-9]+$ ]] || die "Invalid timeout: $timeout_seconds"

	if [[ -n "$serial" ]]; then
		adb_args=(-s "$serial")
	fi

	deadline=$((SECONDS + timeout_seconds))
	while (( SECONDS < deadline )); do
		device_state=$(adb "${adb_args[@]}" get-state 2>/dev/null || true)
		if [[ "$device_state" == "device" ]]; then
			boot_completed=$(adb "${adb_args[@]}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)
			if [[ "$boot_completed" == "1" ]]; then
				log "Android device is ready${serial:+: $serial}"
				return 0
			fi
		fi
		sleep 1
	done

	die "Android device did not finish booting within ${timeout_seconds}s${serial:+: $serial}"
}

open_project() {
	local project_path="${1:-.}"

	[[ -d "$project_path" ]] || die "Project directory not found: $project_path"
	require_command code
	code "$project_path" >/dev/null 2>&1 &
}
