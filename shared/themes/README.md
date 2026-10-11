# Themes

A theme is two small files combined at runtime:

- `palettes/<name>.toml`: text and accent colors, which nvim colorscheme to use
  and, optionally, a `border` color for windows (defaults to the accent)
- `blacks/<name>.toml`: the shared background shades, identical across themes

Switch with `theme <name>` and `theme black <soft|deep>` (see `shared/bin/theme`).
The choice is stored in `~/.local/state/theme/{name,black}`; WezTerm, nvim,
Hyprland, Waybar, starship, tmux, hyprlock and GTK read it from there.
