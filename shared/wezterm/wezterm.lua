local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================================
-- FONT
-- ============================================================

-- Family picked with `theme font <name>` (shared/themes/fonts)
local font_state = (os.getenv('XDG_STATE_HOME') or (wezterm.home_dir .. '/.local/state')) .. '/theme/font'
local font_name = 'jetbrains'
do
  local f = io.open(font_state, 'r')
  if f then
    font_name = f:read('*l') or font_name
    f:close()
  end
end
local font_family = 'JetBrainsMono Nerd Font'
do
  local f = io.open(wezterm.home_dir .. '/.config/themes/fonts/' .. font_name .. '.toml', 'r')
  if f then
    for line in f:lines() do
      font_family = line:match('^family%s*=%s*"(.-)"') or font_family
    end
    f:close()
  end
end
wezterm.add_to_config_reload_watch_list(font_state)

config.font = wezterm.font_with_fallback({
  { family = font_family, weight = 'Medium' },
  'JetBrainsMono Nerd Font',
})

-- Hyprland already scales the UI (1.25 laptop / 2 on the 4K monitor), so the
-- macOS size renders too large on Linux
local is_macos = wezterm.target_triple:find('darwin') ~= nil
config.font_size = is_macos and 13.0 or 9.0


-- ============================================================
-- THEME
-- ============================================================
-- Colors come from the shared theme files (shared/themes), switched with the
-- `theme` command. WezTerm reloads when the saved choice changes.

local themes_dir = wezterm.home_dir .. '/.config/themes'
local state_dir = (os.getenv('XDG_STATE_HOME') or (wezterm.home_dir .. '/.local/state')) .. '/theme'

local function read_line(path, fallback)
  local f = io.open(path, 'r')
  if not f then return fallback end
  local line = f:read('*l')
  f:close()
  return line or fallback
end

-- Parses `key = "value"` lines of a theme file
local function read_theme_file(path)
  local colors = {}
  local f = io.open(path, 'r')
  if not f then return colors end
  for line in f:lines() do
    local key, value = line:match('^(%w[%w_]*)%s*=%s*"(.-)"')
    if key then colors[key] = value end
  end
  f:close()
  return colors
end

local theme_name = read_line(state_dir .. '/name', 'neon')
local black_name = read_line(state_dir .. '/black', 'soft')
local c = read_theme_file(themes_dir .. '/palettes/' .. theme_name .. '.toml')
-- The shared black fills in any background shade the palette does not define
for key, value in pairs(read_theme_file(themes_dir .. '/blacks/' .. black_name .. '.toml')) do
  if c[key] == nil then c[key] = value end
end

wezterm.add_to_config_reload_watch_list(state_dir .. '/name')
wezterm.add_to_config_reload_watch_list(state_dir .. '/black')

if c.bg and c.fg then
  config.color_schemes = {
    ['dotfiles'] = {
      foreground = c.fg,
      background = c.bg,
      cursor_bg = c.accent,
      cursor_fg = c.bg,
      cursor_border = c.accent,
      selection_bg = c.overlay,
      selection_fg = c.fg,
      split = c.line,
      ansi = {
        c.surface, c.red, c.green, c.yellow,
        c.blue, c.magenta, c.cyan, c.fg,
      },
      brights = {
        c.fg_dim, c.bright_red, c.bright_green, c.bright_yellow,
        c.bright_blue, c.bright_magenta, c.bright_cyan, c.bright_white or '#ffffff',
      },
      tab_bar = {
        background = c.bg,
        active_tab = { bg_color = c.accent, fg_color = c.bg },
        inactive_tab = { bg_color = c.bg_alt, fg_color = c.fg_dim },
        inactive_tab_hover = { bg_color = c.surface, fg_color = c.fg },
        new_tab = { bg_color = c.bg, fg_color = c.fg_dim },
        new_tab_hover = { bg_color = c.surface, fg_color = c.fg },
      },
    },
  }
  config.color_scheme = 'dotfiles'
end


-- ============================================================
-- BACKGROUND
-- ============================================================
-- The image is not tracked in the repo (heavy/personal), so when it is missing
-- on this machine, or `bg color` turned it off, the theme's flat background is
-- used instead of breaking the config.

local function file_exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

local function read_bg_mode()
  local state_file = wezterm.home_dir .. '/.local/state/wezterm/bg_mode'
  local f = io.open(state_file, 'r')
  if not f then
    return 'image'
  end
  local mode = f:read('*l')
  f:close()
  return mode or 'image'
end

local bg_image_path = wezterm.config_dir .. '/4761574.jpg'

if read_bg_mode() == 'image' and file_exists(bg_image_path) then
  config.background = {
    {
      source = {
        File = bg_image_path,
      },
      hsb = {
        brightness = 0.1,
        saturation = 1.0,
      },
      opacity = 1.0,
    },
  }
end


-- ============================================================
-- WINDOW
-- ============================================================

-- macOS: resizable without a title bar. Linux: no decorations at all; Hyprland
-- already moves, resizes and closes windows, and WezTerm's own Wayland frame
-- (a gray bar with buttons) also raised "font problem" warnings for its title.
config.window_decorations = is_macos and "RESIZE" or "NONE"

-- macOS: slight transparency so the compositor blur shows through. Linux:
-- opaque, because Hyprland recomputes the blur behind a translucent window on
-- every terminal redraw, which is expensive on the 4K monitor
config.window_background_opacity = is_macos and 0.88 or 1.0
config.macos_window_background_blur = 20

config.window_padding = {
  left = 12,
  right = 12,
  top = 10,
  bottom = 10,
}

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false


-- ============================================================
-- CURSOR
-- ============================================================

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 700
-- Hard on/off blink: the default fade redraws at animation_fps (and makes
-- Hyprland recompute the blur behind the window) for the whole blink cycle
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'


-- ============================================================
-- SCROLLBACK
-- ============================================================

config.scrollback_lines = 10000


-- ============================================================
-- RENDERING
-- ============================================================

config.animation_fps = 60
-- 120 for the laptop's 120 Hz panel; on 60 Hz monitors Wayland frame
-- callbacks already keep WezTerm from drawing frames that are never shown
config.max_fps = 120

-- Default OpenGL renderer. Rendering on the Intel iGPU (WebGpu LowPower) left
-- new windows black while Hyprland runs on the NVIDIA GPU; the freezes under
-- full VRAM while gaming are handled with the GPU setup (phase 5) instead.


-- ============================================================
-- KEYS
-- ============================================================
-- macOS-style shortcuts on SUPER: Cmd on macOS, and on Linux keyd's
-- per-app map (linux/keyd/app.conf) sends Cmd as SUPER while WezTerm is
-- focused. Real Ctrl stays free for the shell, tmux and nvim.

local act = wezterm.action

-- Cmd+C: copy the terminal selection to the system clipboard. Without a
-- selection, forward Ctrl+Insert so nvim can copy its visual selection.
local copy_or_forward = wezterm.action_callback(function(window, pane)
  local selection = window:get_selection_text_for_pane(pane)
  if selection ~= '' then
    window:perform_action(act.CopyTo('Clipboard'), pane)
    window:perform_action(act.ClearSelection, pane)
  else
    window:perform_action(act.SendKey({ key = 'Insert', mods = 'CTRL' }), pane)
  end
end)

config.keys = {
  -- Clipboard
  { key = 'c', mods = 'SUPER', action = copy_or_forward },
  { key = 'v', mods = 'SUPER', action = act.PasteFrom('Clipboard') },

  -- Tabs
  { key = 't', mods = 'SUPER', action = act.SpawnTab('CurrentPaneDomain') },
  { key = '[', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },
  { key = '{', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },

  -- Splits (Cmd+W closes the pane, or the tab when it is the last pane)
  { key = 'd', mods = 'SUPER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'd', mods = 'SUPER|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'D', mods = 'SUPER|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = '[', mods = 'SUPER', action = act.ActivatePaneDirection('Prev') },
  { key = ']', mods = 'SUPER', action = act.ActivatePaneDirection('Next') },
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentPane({ confirm = true }) },

  -- Misc
  { key = 'n', mods = 'SUPER', action = act.SpawnWindow },
  { key = 'f', mods = 'SUPER', action = act.Search('CurrentSelectionOrEmptyString') },
  { key = 'k', mods = 'SUPER', action = act.ClearScrollback('ScrollbackAndViewport') },
  { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
  { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
  { key = '0', mods = 'SUPER', action = act.ResetFontSize },

  -- Swallow Cmd keys with no terminal meaning so they never reach the shell
  { key = 'a', mods = 'SUPER', action = act.Nop },
  { key = 'x', mods = 'SUPER', action = act.Nop },
  { key = 'z', mods = 'SUPER', action = act.Nop },
}

-- Cmd+1..9: jump to tab N (Hyprland desktops use Ctrl+1..9, like macOS)
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'SUPER', action = act.ActivateTab(i - 1) })
end


return config
