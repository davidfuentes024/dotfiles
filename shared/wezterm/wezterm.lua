local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ============================================================
-- FUENTE
-- ============================================================

config.font = wezterm.font('JetBrains Mono', {
  weight = 'Medium',
})

-- Hyprland already scales the UI (1.25 laptop / 2 on the 4K monitor), so the
-- macOS size renders too large on Linux
local is_macos = wezterm.target_triple:find('darwin') ~= nil
config.font_size = is_macos and 13.0 or 9.0


-- ============================================================
-- TEMA
-- ============================================================

-- One Dark Pro "Darker" palette on a neutral soft-black background. Defined inline because
-- WezTerm's bundled One Dark variants use the lighter, bluer #282c34 background.
config.color_schemes = {
  ['One Dark Pro Darker'] = {
    foreground = '#abb2bf',
    background = '#1c1c1e',
    cursor_bg = '#528bff',
    cursor_fg = '#1c1c1e',
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

-- Slight transparency so the compositor blur (Hyprland/macOS) shows through
config.window_background_opacity = 0.88
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


-- ============================================================
-- SCROLLBACK
-- ============================================================

config.scrollback_lines = 10000


-- ============================================================
-- RENDERIZADO
-- ============================================================

config.animation_fps = 60
config.max_fps = 120

-- Render on the Intel iGPU: the RTX 3050 only has 4 GB of VRAM and games fill
-- it, which made WezTerm fail with EGL BAD_ALLOC and freeze its windows
if not is_macos then
  config.front_end = 'WebGpu'
  config.webgpu_power_preference = 'LowPower'
end


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
