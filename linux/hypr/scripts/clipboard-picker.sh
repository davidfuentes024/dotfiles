#!/usr/bin/env bash
# Pick an entry from the clipboard history (cliphist) and put it back on the
# clipboard, ready to paste with Cmd+V.
set -euo pipefail

selection=$(cliphist list | hyprlauncher --dmenu) || exit 0
[ -n "$selection" ] || exit 0
printf '%s' "$selection" | cliphist decode | wl-copy
