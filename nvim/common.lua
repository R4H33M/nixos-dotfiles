-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- enable line numbers
vim.wo.number = true

-- disable mouse control
vim.opt.mouse = ''

-- set the encoding
vim.opt.encoding = "utf-8"

-- disable swap file
vim.opt.swapfile = false

-- maximum number of suggestions
vim.opt.pumheight = 5

-- minimum number of screenlines visible
vim.opt.scrolloff = 10

-- use the clipboard when yanking and pasting
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Decrease update time
vim.opt.updatetime = 250

-- Decreased mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- (Don't) Show which line your cursor is on
-- vim.opt.cursorline = true

-- don't show mode because we already have a bar
vim.opt.showmode = false

-- keep at least 7 lines of context around the cursor
vim.opt.scrolloff = 7

-- tabs should be 4 spaces both when displayed and when editing
vim.opt.tabstop = 8
vim.opt.softtabstop = 0

-- set indentation width to 4 for commands like >> and <<
vim.opt.shiftwidth = 4
vim.opt.fixeol = false 

-- maintain current line indentation when starting new line
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.smarttab = true

-- use unix line endings
vim.opt.fileformat = "unix"

