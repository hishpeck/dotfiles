return {
	"lukas-reineke/indent-blankline.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {},
}
