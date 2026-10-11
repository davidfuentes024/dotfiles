#!/usr/bin/env bash
# Clone this repo anywhere (recommended: ~/dotfiles) and run this script.
# It symlinks configs from $HOME into the repo: shared/ on every OS, plus
# linux/ or macos/ depending on the current system. If a real file/dir (not a
# symlink) already exists at the destination, it is moved to <name>.bak
# instead of being deleted.
#
# System files under linux/etc are NOT handled here (they need root): run
# linux/install-etc.sh for those.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "Backing up $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Linked: $dest -> $src"
}

# Removes a symlink left by an older layout of this repo, never a real file
unlink_stale() {
  local dest="$1"
  if [ -L "$dest" ] && [[ "$(readlink "$dest")" == "$DOTFILES_DIR"/* ]]; then
    rm "$dest"
    echo "Removed stale link: $dest"
  fi
}

link_shared() {
  link "$DOTFILES_DIR/shared/nvim"       "$HOME/.config/nvim"
  link "$DOTFILES_DIR/shared/wezterm"    "$HOME/.config/wezterm"
  link "$DOTFILES_DIR/shared/tmux"       "$HOME/.config/tmux"
  link "$DOTFILES_DIR/shared/zsh/zshrc"  "$HOME/.zshrc"
  # tmux now loads only from ~/.config/tmux
  unlink_stale "$HOME/.tmux.conf"
}

link_linux() {
  link "$DOTFILES_DIR/linux/hypr"    "$HOME/.config/hypr"
  link "$DOTFILES_DIR/linux/waybar"  "$HOME/.config/waybar"
}

link_macos() {
  : # macOS-specific configs are sourced from the repo (macos/zsh); nothing to link yet
}

link_shared
case "$(uname -s)" in
  Linux)  link_linux ;;
  Darwin) link_macos ;;
  *)      echo "Unknown OS: only shared/ configs were linked" ;;
esac

# Versioned git hooks (gitleaks secret scan before each commit)
git -C "$DOTFILES_DIR" config core.hooksPath hooks

echo
echo "Done. Remaining manual steps:"
echo "  - Open nvim once so lazy.nvim installs the plugins."
echo "  - Inside tmux, press prefix + I so tpm installs its plugins."
echo "  - Install gitleaks (required by the pre-commit hook)."
echo "  - Put private env vars in shared/zsh/secrets.zsh (gitignored)."
if [ "$(uname -s)" = "Linux" ]; then
  echo "  - Run linux/install-etc.sh to review and install system files (needs sudo)."
fi
