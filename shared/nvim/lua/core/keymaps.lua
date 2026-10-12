local keymap = vim.keymap

-- Guardar archivo
keymap.set('n', '<space>w', ':w<CR>', { noremap = true, silent = true })

-- Salir del modo terminal
keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Salir del modo terminal' })

-- Cmd+C: WezTerm forwards it as Ctrl+Insert when there is no terminal selection.
-- Copies the visual selection to the system clipboard; y/d/p stay nvim-only.
keymap.set('x', '<C-Insert>', '"+y', { desc = 'Copy selection to system clipboard' })
