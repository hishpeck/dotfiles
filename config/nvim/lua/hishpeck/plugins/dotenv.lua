return {
	"ellisonleao/dotenv.nvim",
	event = "VeryLazy",
	config = function()
		require("dotenv").setup({
			enable_on_load = true,
			verbose = false,
		})
	end,
}
