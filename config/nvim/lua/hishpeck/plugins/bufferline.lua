return {
	"akinsho/bufferline.nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	opts = {
		options = {
			mode = "tabs",
			separator_style = "thin",
		},
		-- highlights = require("catppuccin.groups.integrations.bufferline").get(),
	},
}
