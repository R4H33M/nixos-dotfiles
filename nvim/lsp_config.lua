local nvim_lsp = require("lspconfig")
local map = vim.api.nvim_set_keymap

-- Mappings

-- Type Definition, disabled because it doesn't look very good right now
-- map("n", "<space>D", "<cmd> lua vim.lsp.buf.type_definition()<CR>", opts)

-- Rename Symbol
map("n", "<space>r", "<cmd> lua vim.lsp.buf.rename()<CR>", {desc = "[R]ename"})
map("n", "<leader>gd", '<cmd>lua vim.lsp.buf.definition()<CR>', {desc = "[G]o to [D]efinition"})
map("n", "<leader>gl", "<cmd>lua vim.lsp.buf.declaration()<CR>", {desc = "[G] to dec[L}aration"})
map("n", "<leader>cf", "<cmd>lua vim.lsp.buf.format()<CR>", {desc = "[C]ode [F]ormat"})


--[[ Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function ()
		vim.lsp.buf.format({
			async = false,
		})
	end,
})
]] --
--
local servers = {
--	"lua_ls",
	"pyright",
--	"rust_analyzer",
   "clangd",
--	"ts_ls",
--	"svlangserver"
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, lsp in ipairs(servers) do
	nvim_lsp[lsp].setup({
		capabilities = capabilities,
	})
end

--[[
nvim_lsp["svlangserver"].setup({
	on_init = function(client)

      client.config.settings.systemverilog = {
        includeIndexing     = {"**/*.{v,svh}"},
        excludeIndexing     = {"test/**/*.sv*"},
        defines             = {},
        launchConfiguration = "iverilog -I ~/mount/lab2/riscvbyp -I ~/mount/lab2/imuldiv -I ~/mount/lab2/vc -t null",
		linter = "icarus"
      }

    client.notify("workspace/didChangeConfiguration")
    return true
 end
})
--]]
