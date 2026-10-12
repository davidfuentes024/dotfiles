local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.wrap = true
opt.linebreak = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.termguicolors = true

-- Configuración visual de diagnósticos
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
})
