return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		options = {
			parsers = {
				-- names highlight immediately, then the Tailwind LSP corrects them with
				-- colors from the project's theme config
				tailwind = {
					enable = true,
					lsp = true,
					update_names = true,
				},
			},
		},
	},
}
