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

config.color_scheme = 'Catppuccin Mocha'


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
