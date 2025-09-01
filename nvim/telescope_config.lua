local keymap = vim.keymap.set
local fzf_lua = require("fzf-lua")

local actions = fzf_lua.actions
actions = {
    -- Below are the default actions, setting any value in these tables will override
    -- the defaults, to inherit from the defaults change [1] from `false` to `true`
    files = {
      true,        -- uncomment to inherit all the below in your custom config
      -- Pickers inheriting these actions:
      --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
      --   tags, btags, args, buffers, tabs, lines, blines
      -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
      -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
      -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
      ["ctrl-t"]             = actions.file_vsplit,
      ["enter"]             = actions.file_switch_or_edit,
    },
  }

fzf_lua.setup{
	files = {
		git_icons = true,
	},
	git = {
		git_icons = true,
	},
	grep = {
		git_icons = true,
	},
	lsp = {
		git_icons = true,
	},
        actions = actions,
}

keymap("n", "<leader>sf", fzf_lua.files, {desc = "[S]earch [F]iles" })

keymap("n", "<leader>sg", fzf_lua.grep_project, {desc = "[S]earch by [G]rep"})

keymap("n", "<leader>sd", fzf_lua.diagnostics_document, {desc = "[S]earch [D]iagnostics"})

keymap("n", "<leader>ds", fzf_lua.lsp_document_symbols, {desc = "[D]ocument [S]ymbols"})

keymap("n", "<leader>sr", fzf_lua.lsp_references, {desc = "[S]earch [R]eferences"})


