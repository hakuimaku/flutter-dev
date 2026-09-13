#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/local/bin"

if (( EUID != 0 )); then
	command -v sudo >/dev/null 2>&1 || {
		printf 'Error: sudo is required to uninstall scripts from %s\n' "$INSTALL_DIR" >&2
		exit 1
	}
	SUDO=(sudo)
else
	SUDO=()
fi

for source_script in "$SCRIPT_DIR"/src/*.sh; do
	[[ -f "$source_script" ]] || continue
	"${SUDO[@]}" rm -f -- "$INSTALL_DIR/$(basename "$source_script")"
done

printf 'Removed Flutter development scripts from %s\n' "$INSTALL_DIR"