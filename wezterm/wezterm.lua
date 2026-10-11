local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================================
-- FUENTE
-- ============================================================

config.font = wezterm.font('JetBrains Mono', {
  weight = 'Medium',
})

config.font_size = 13.0


-- ============================================================
-- TEMA
-- ============================================================

-- One Dark Pro "Darker" (VS Code theme palette). Defined inline because
-- WezTerm's bundled One Dark variants use the lighter, bluer #282c34 background.
config.color_schemes = {
  ['One Dark Pro Darker'] = {
    foreground = '#abb2bf',
    background = '#23272e',
    cursor_bg = '#528bff',
    cursor_fg = '#23272e',
    cursor_border = '#528bff',
    selection_bg = '#3e4451',
    selection_fg = '#abb2bf',
    split = '#3e4451',
    ansi = {
      '#3f4451', '#e05561', '#8cc265', '#d18f52',
      '#4aa5f0', '#c162de', '#42b3c2', '#d7dae0',
    },
    brights = {
      '#4f5666', '#ff616e', '#a5e075', '#f0a45d',
      '#4dc4ff', '#de73ff', '#4cd1e0', '#e6e6e6',
    },
  },
}

config.color_scheme = 'One Dark Pro Darker'


-- ============================================================
-- FONDO
-- ============================================================
-- La imagen no viaja en el repo de dotfiles (es pesada/personal), así que
-- si no está presente en este equipo, o si `bg color` la desactivó, cae al
-- fondo plano del color_scheme en vez de romper la config.

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
-- VENTANA
-- ============================================================

config.window_decorations = "RESIZE"

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


-- ============================================================
-- SCROLLBACK
-- ============================================================

config.scrollback_lines = 10000


-- ============================================================
-- RENDERIZADO
-- ============================================================

config.animation_fps = 60
config.max_fps = 120


return config
