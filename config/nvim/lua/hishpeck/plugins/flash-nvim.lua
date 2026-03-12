return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		jump = {
			autojump = true,
		},
	},
	keys = {
		{
			"<leader><leader>",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"<leader>>",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter Selection",
		},
		{
			"<leader>/",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
	},
}
