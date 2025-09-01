local map = vim.api.nvim_set_keymap

-- switching windows
map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })
map("n", "<C-q>", "<C-w>c", { desc = "close window" })

-- nvim tree

map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle nvimtree window" })

-- barbar

-- map("n", "<Tab>", "<Cmd>BufferNext<CR>", { desc = "switch tab" })
-- map("n", "<C-w>", "<Cmd>BufferClose<CR>", { desc = "close tab" })

-- other

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Open Diagnostics 
vim.keymap.set('n', '<leader>q', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true, desc = "[Q]uickfix current line" })

--vim.keymap.set('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {})
