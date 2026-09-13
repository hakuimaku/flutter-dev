#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/local/bin"

if (( EUID != 0 )); then
	command -v sudo >/dev/null 2>&1 || {
		printf 'Error: sudo is required to install scripts into %s\n' "$INSTALL_DIR" >&2
		exit 1
	}
	SUDO=(sudo)
else
	SUDO=()
fi

"${SUDO[@]}" install -d -m 0755 "$INSTALL_DIR"

found_script=false
for source_script in "$SCRIPT_DIR"/src/*.sh; do
	[[ -f "$source_script" ]] || continue
	found_script=true
	"${SUDO[@]}" install -m 0755 "$source_script" "$INSTALL_DIR/$(basename "$source_script")"
done

if [[ "$found_script" != true ]]; then
	printf 'Error: no shell scripts found in %s/src\n' "$SCRIPT_DIR" >&2
	exit 1
fi

printf 'Installed Flutter development scripts into %s\n' "$INSTALL_DIR"