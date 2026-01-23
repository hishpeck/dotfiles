return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		image = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scratch = { enabled = true },
		scroll = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		{
			"<leader>.",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>Lg",
			function()
				Snacks.lazygit.open()
			end,
			desc = "Open Lazygit",
		},
		{
			"<leader>Lf",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Lazygit File Log",
		},
	},
}
