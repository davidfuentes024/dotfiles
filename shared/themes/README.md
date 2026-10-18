# Themes

A theme is two small files combined at runtime:

- `palettes/<name>.toml`: text and accent colors, which nvim colorscheme to use
  and, optionally, a `border` color for windows (defaults to the accent) and
  its own background shades (`bg`, `bg_alt`, `surface`, `overlay`)
- `blacks/<name>.toml`: shared background shades, used by any palette that does
  not define its own

Switch with `theme <name>` and `theme black <soft|deep>` (see `shared/bin/theme`).
The choice is stored in `~/.local/state/theme/{name,black}`; WezTerm, nvim,
Hyprland, Quickshell, starship, tmux, hyprlock and GTK read it from there.
