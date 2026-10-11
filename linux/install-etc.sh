#!/usr/bin/env bash
# Installs the system files kept under linux/etc into /etc.
# /etc is root-owned, so files are copied (not symlinked). For each file that
# differs, the diff is shown and nothing is written without confirmation.
# The previous version is kept as <file>.bak.
#
# Usage: install-etc.sh [--yes]   (--yes installs without asking, e.g. when
# there is no interactive terminal to answer the prompt)
set -euo pipefail

assume_yes=false
[ "${1:-}" = "--yes" ] && assume_yes=true

ETC_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/etc"

while IFS= read -r -d '' src; do
  rel="${src#"$ETC_SRC"/}"
  dest="/etc/$rel"

  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    echo "Up to date: $dest"
    continue
  fi

  echo "=== $dest ==="
  if [ -f "$dest" ]; then
    diff -u "$dest" "$src" || true
  else
    echo "(new file)"
    cat "$src"
  fi

  if $assume_yes; then
    answer=y
  elif ! { read -r -p "Install $dest? [y/N] " answer < /dev/tty; } 2>/dev/null; then
    echo "No interactive terminal to confirm; re-run with --yes after reviewing the diff above." >&2
    exit 1
  fi
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    [ -f "$dest" ] && sudo cp -p "$dest" "$dest.bak"
    sudo install -D -m 644 "$src" "$dest"
    echo "Installed: $dest"
  else
    echo "Skipped: $dest"
  fi
done < <(find "$ETC_SRC" -type f -print0)

echo
echo "Reminder: some services need a restart to pick up changes (e.g. sudo systemctl restart keyd)."
