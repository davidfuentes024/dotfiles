# Themes

A theme is two small files combined at runtime:

- `palettes/<name>.toml`: text and accent colors and, optionally, a `border` color for windows (defaults to the accent) and
  its own background shades (`bg`, `bg_alt`, `surface`, `overlay`)
- `blacks/<name>.toml`: shared background shades, used by any palette that does
  not define its own

Switch with `theme <name>` and `theme black <soft|deep>` (see `shared/bin/theme`).
The choice is stored in `~/.local/state/theme/{name,black}`; WezTerm, nvim,
Hyprland, Quickshell, starship, tmux, hyprlock and GTK read it from there.

## Variants and measurement

- `<name>-deep` palettes: the same colors on darker backgrounds, for comparing.
- `paper` and `daylight`: light themes kept for presentations and samples.
- `theme check [--md] [name]` measures WCAG contrast (text 7:1, `fg` 14:1,
  separator `line` and cursor 3:1); `CONTRAST.md` is its latest report.
- Palettes can set `bright_white` (the ANSI bright white, `#ffffff` by default);
  the light ones need it dark.
