-- 1. Definir la tecla líder antes de cargar cualquier plugin
vim.g.mapleader = " "

-- 2. Cargar configuraciones base
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- 3. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- 4. Cargar plugins automáticamente desde lua/plugins/
require("lazy").setup("plugins")
