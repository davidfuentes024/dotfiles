-- Applies the active theme (shared/themes, switched with the `theme` command).
-- Each theme maps to a real colorscheme plugin; the background stays
-- transparent so the terminal's shared black shows through.
local M = {}

local state_dir = (vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")) .. "/theme"
local themes_dir = vim.fn.expand("~/.config/themes")

local function read_line(path, fallback)
  local f = io.open(path, "r")
  if not f then return fallback end
  local line = f:read("*l")
  f:close()
  return line or fallback
end

-- Parses `key = "value"` lines of a theme file
local function read_theme_file(path)
  local values = {}
  local f = io.open(path, "r")
  if not f then return values end
  for line in f:lines() do
    local key, value = line:match('^(%w[%w_]*)%s*=%s*"(.-)"')
    if key then values[key] = value end
  end
  f:close()
  return values
end

local function current_choice()
  return read_line(state_dir .. "/name", "neon"), read_line(state_dir .. "/black", "soft")
end

local function load_colors(name, black)
  local colors = read_theme_file(themes_dir .. "/palettes/" .. name .. ".toml")
  for key, value in pairs(read_theme_file(themes_dir .. "/blacks/" .. black .. ".toml")) do
    colors[key] = value
  end
  return colors
end

local appliers = {
  onedarkpro = function(c)
    require("onedarkpro").setup({
      colors = {
        onedark_dark = {
          bg = c.bg, fg = c.fg, comment = c.fg_dim,
          red = c.red, orange = c.accent_alt, yellow = c.yellow, green = c.green,
          cyan = c.cyan, blue = c.blue, purple = c.magenta,
        },
      },
      options = { transparency = true, highlight_inactive_windows = false },
    })
    vim.cmd.colorscheme("onedark_dark")
  end,

  -- The colorscheme exactly as it was before the theme system
  onedark = function()
    require("onedarkpro").setup({
      options = { transparency = true, highlight_inactive_windows = false },
    })
    vim.cmd.colorscheme("onedark")
  end,

  kanagawa = function(c)
    require("lazy").load({ plugins = { "kanagawa.nvim" } })
    require("kanagawa").setup({
      theme = "dragon",
      background = { dark = "dragon" },
      transparent = true,
      colors = {
        -- Our palette is a livelier Dragon; map it onto Kanagawa's names
        palette = {
          dragonRed = c.red, dragonGreen = c.green, dragonGreen2 = c.bright_green,
          dragonYellow = c.yellow, dragonBlue2 = c.blue, dragonViolet = c.magenta,
          dragonAqua = c.cyan, dragonOrange = c.accent_alt, dragonWhite = c.fg,
          dragonGray = c.fg_dim,
        },
        theme = { all = { ui = { bg_gutter = "none" } } },
      },
    })
    vim.cmd.colorscheme("kanagawa-dragon")
  end,

  vesper = function()
    require("lazy").load({ plugins = { "vesper.nvim" } })
    require("vesper").setup({ transparent = true })
    vim.cmd.colorscheme("vesper")
  end,
}

local applied

function M.apply()
  local name, black = current_choice()
  local colors = load_colors(name, black)
  local apply_scheme = appliers[colors.nvim or "onedarkpro"] or appliers.onedarkpro
  apply_scheme(colors)
  applied = name .. "/" .. black
  return applied
end

-- Catches theme switches made while this nvim had no server socket
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("dotfiles_theme", { clear = true }),
  callback = function()
    local name, black = current_choice()
    if applied ~= name .. "/" .. black then M.apply() end
  end,
})

return M
