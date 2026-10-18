-- Colors for the whole editor, taken from the active theme (shared/themes,
-- switched with the `theme` command). There is no colorscheme plugin: every
-- highlight group is built from the same palette the terminal uses, and the
-- background stays transparent so the terminal's own shows through.
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
    -- The palette's own background shades win over the shared black
    if colors[key] == nil then colors[key] = value end
  end
  return colors
end

local function highlights(c)
  local none = "NONE"
  return {
    -- Editor
    Normal = { fg = c.fg, bg = none },
    NormalNC = { link = "Normal" },
    NormalFloat = { fg = c.fg, bg = c.bg_alt },
    FloatBorder = { fg = c.fg_dim, bg = c.bg_alt },
    FloatTitle = { fg = c.accent, bg = c.bg_alt, bold = true },
    Cursor = { fg = c.bg, bg = c.accent },
    CursorLine = { bg = c.surface },
    CursorLineNr = { fg = c.accent, bold = true },
    LineNr = { fg = c.fg_dim },
    SignColumn = { bg = none },
    ColorColumn = { bg = c.surface },
    Visual = { bg = c.overlay },
    Search = { fg = c.bg, bg = c.accent_alt },
    CurSearch = { fg = c.bg, bg = c.accent },
    IncSearch = { link = "CurSearch" },
    MatchParen = { fg = c.accent, bold = true, underline = true },
    NonText = { fg = c.fg_dim },
    EndOfBuffer = { fg = c.overlay },
    Whitespace = { fg = c.overlay },
    WinSeparator = { fg = c.overlay },
    Folded = { fg = c.fg_dim, bg = c.surface },
    Title = { fg = c.accent, bold = true },
    Directory = { fg = c.blue },
    Conceal = { fg = c.fg_dim },
    Question = { fg = c.green },
    MoreMsg = { fg = c.green },
    WarningMsg = { fg = c.accent_alt },
    ErrorMsg = { fg = c.red },
    StatusLine = { fg = c.fg, bg = c.bg_alt },
    StatusLineNC = { fg = c.fg_dim, bg = c.bg_alt },
    TabLine = { fg = c.fg_dim, bg = c.bg_alt },
    TabLineSel = { fg = c.bg, bg = c.accent },
    TabLineFill = { bg = c.bg_alt },
    Pmenu = { fg = c.fg, bg = c.bg_alt },
    PmenuSel = { fg = c.fg, bg = c.overlay, bold = true },
    PmenuSbar = { bg = c.surface },
    PmenuThumb = { bg = c.fg_dim },
    SpellBad = { undercurl = true, sp = c.red },
    SpellCap = { undercurl = true, sp = c.accent_alt },

    -- Syntax (tree-sitter captures fall back to these)
    Comment = { fg = c.fg_dim, italic = true },
    Constant = { fg = c.yellow },
    String = { fg = c.green },
    Number = { fg = c.accent_alt },
    Identifier = { fg = c.fg },
    Function = { fg = c.blue },
    Statement = { fg = c.magenta },
    Operator = { fg = c.cyan },
    PreProc = { fg = c.cyan },
    Type = { fg = c.yellow },
    Special = { fg = c.cyan },
    Delimiter = { fg = c.fg },
    Underlined = { fg = c.blue, underline = true },
    Error = { fg = c.red },
    Todo = { fg = c.bg, bg = c.accent_alt, bold = true },
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.red },
    ["@variable.parameter"] = { fg = c.red },
    ["@variable.member"] = { fg = c.cyan },
    ["@property"] = { fg = c.cyan },
    ["@constructor"] = { fg = c.yellow },
    ["@function.builtin"] = { fg = c.cyan },
    ["@tag"] = { fg = c.red },
    ["@tag.attribute"] = { fg = c.yellow },
    ["@tag.delimiter"] = { fg = c.fg_dim },
    ["@markup.heading"] = { fg = c.magenta, bold = true },
    ["@markup.link"] = { fg = c.blue, underline = true },
    ["@markup.raw"] = { fg = c.green },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },

    -- Diagnostics and git
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.accent_alt },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.cyan },
    DiagnosticOk = { fg = c.green },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.accent_alt },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.cyan },
    Added = { fg = c.green },
    Changed = { fg = c.yellow },
    Removed = { fg = c.red },
    DiffAdd = { fg = c.green, bg = c.surface },
    DiffChange = { fg = c.yellow, bg = c.surface },
    DiffDelete = { fg = c.red, bg = c.surface },
    DiffText = { fg = c.fg, bg = c.overlay, bold = true },

    -- Plugins
    TelescopeSelection = { link = "PmenuSel" },
    TelescopeMatching = { fg = c.accent, bold = true },
    TelescopeBorder = { link = "FloatBorder" },
    CmpItemAbbrMatch = { fg = c.accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = c.accent, bold = true },
    CmpItemAbbrDeprecated = { fg = c.fg_dim, strikethrough = true },
    CmpItemMenu = { fg = c.fg_dim },
    NeoTreeNormal = { link = "Normal" },
    NeoTreeNormalNC = { link = "Normal" },
    AlphaHeader = { fg = c.accent },
    AlphaButtons = { fg = c.fg },
    AlphaShortcut = { fg = c.accent },
  }
end

-- The :terminal palette, same order as the terminal's ansi colors
local function terminal_colors(c)
  local ansi = {
    c.surface, c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, c.fg,
    c.fg_dim, c.bright_red, c.bright_green, c.bright_yellow, c.bright_blue,
    c.bright_magenta, c.bright_cyan, "#ffffff",
  }
  for i, color in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

local applied

function M.apply()
  local name, black = current_choice()
  local c = load_colors(name, black)
  vim.cmd("highlight clear")
  vim.g.colors_name = "dotfiles"
  for group, spec in pairs(highlights(c)) do
    vim.api.nvim_set_hl(0, group, spec)
  end
  terminal_colors(c)
  -- Lets plugins that derive colors from highlights (lualine) refresh
  vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
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
