local vim = vim

-- Need to install vim-plug imperatively
local Plug = vim.fn['plug#']

vim.call("plug#begin")

Plug("catppuccin/nvim", { ["as"] = 'catppuccin' })

Plug("nvim-tree/nvim-tree.lua")
Plug("nvim-tree/nvim-web-devicons")
-- Plug("romgrk/barbar.nvim")
Plug('nvim-lualine/lualine.nvim')
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" })
Plug("neovim/nvim-lspconfig")
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('L3MON4D3/LuaSnip')
Plug("saadparwaiz1/cmp_luasnip")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")
Plug("ibhagwan/fzf-lua", { ["branch"] = "main" })
Plug("folke/which-key.nvim")
Plug("numToStr/Comment.nvim")
Plug("lewis6991/gitsigns.nvim")

vim.call("plug#end")

local home = os.getenv("HOME")
package.path = home .. "/.config/nvim/?.lua;" .. package.path

require "common"
require "theme"
require "vimtree"
require "mappings"
-- require "barbar_config"
require "lualine_config"
require "lsp_config"
require "treesitter_config"
require "cmp_config"
require "telescope_config"

-- highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

--[[
vim.api.nvim_create_autocmd('BufWritePost', {
	desc = 'use the black formatter on python files after saving',
	group = vim.api.nvim_create_augroup('black-formatter', { clear = true }),
	pattern = '*.py',
	callback = function()
		vim.cmd("!black <afile>")
	end,
})
]]

-- fix the color scheme for selected file barbar
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "BufferCurrent", { fg = "black" })
	end,
})

-- helper for remembering keyboard shortcuts
local wk = require("which-key")
wk.setup({
	triggers = {
		{ "<leader>", mode = { "n", "v" } },
	}
})
wk.add({
	{ "<leader>s", group = "[S]earch", icon = { icon = "" } },
	{ "<leader>d", group = "[D]ocument" },
	{ "<leader>c", group = "[C]ode" },
	{ "<leader>g", group = "[G]oto" },
})

-- case insensitive matching unless we put uppercase
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- commenting
require("Comment").setup({
	toggler = {
		line = "/",
	}
})

-- set search to control f
vim.api.nvim_set_keymap('n', '<C-f>', '/', { noremap = true, silent = true })
