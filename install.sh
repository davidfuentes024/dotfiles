#!/usr/bin/env bash
# Clona este repo donde quieras (recomendado: ~/dotfiles) y corre este script.
# Crea symlinks desde tu $HOME/.config hacia este repo. Si ya existe un
# archivo/carpeta real (no symlink) en el destino, lo respalda con sufijo .bak
# en vez de borrarlo.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "Respaldando $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "Enlazado: $dest -> $src"
}

link "$DOTFILES_DIR/nvim"        "$HOME/.config/nvim"
link "$DOTFILES_DIR/wezterm"     "$HOME/.config/wezterm"
link "$DOTFILES_DIR/tmux"        "$HOME/.config/tmux"
link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/zsh/zshrc"   "$HOME/.zshrc"

echo
echo "Listo. Pasos manuales que quedan:"
echo "  - Abre nvim una vez para que lazy.nvim instale los plugins."
echo "  - Dentro de tmux, presiona prefix + I para que tpm instale sus plugins."
echo "  - Si quieres el fondo con imagen de WezTerm, copia tu imagen a"
echo "    $DOTFILES_DIR/wezterm/ (no viaja en el repo) y corre 'bg image'."
