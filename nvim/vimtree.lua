-- disable netrw at the very start of your init.lua
-- this is vim's builtin file explorer 
vim.g.loaded_netrw = 1
vim.g.loaded_newrwPlugin = 1

-- enable 24-bit color
vim.opt.termguicolors = true

local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return {
			desc = "nvim-tree :" .. desc,
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true
		}
	end

	vim.keymap.set("n", "a", api.fs.create, opts("New File"))
	vim.keymap.set("n", "d", api.fs.remove, opts("Delete File"))
	vim.keymap.set("n", "r", api.fs.rename, opts("Rename File"))
	vim.keymap.set("n", "<cr>", 
		api.node.open.edit, opts("Open in Place"))
end

-- empty setup using defaults
require("nvim-tree").setup({
	on_attach = my_on_attach,
	hijack_cursor = true,
	actions = {
		open_file = {
			quit_on_open = true
		}
	}
})
