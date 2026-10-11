local autocmd = vim.api.nvim_create_autocmd

-- Reglas de Go
autocmd("FileType", {
  pattern = { "go", "gomod", "gowork" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Reglas de Java
autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Reglas de Markdown
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.keymap.set('n', 'j', 'gj', { buffer = true })
    vim.keymap.set('n', 'k', 'gk', { buffer = true })
  end,
})
