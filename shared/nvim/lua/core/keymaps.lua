local keymap = vim.keymap

-- Guardar archivo
keymap.set('n', '<space>w', ':w<CR>', { noremap = true, silent = true })

-- Salir del modo terminal
keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Salir del modo terminal' })
