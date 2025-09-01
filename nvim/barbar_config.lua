vim.g.barbar_auto_setup = false -- disable auto-setup

require("barbar").setup({


	auto_hide =  false,

	exclude_ft = {"javascript"},
	exclude_name = {"package.json"},

	focus_on_close = "left",


})
