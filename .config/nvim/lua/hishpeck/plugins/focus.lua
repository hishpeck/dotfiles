return {
	"nvim-focus/focus.nvim",
	keys = {
		{ "<leader>sm", "<cmd>FocusMaxOrEqual<CR>", desc = "Maximize/minimize a split" },
	},
	opts = {
		ui = {
			absolutenumber_unfocussed = true,
			winhighlight = true,
		},
	},
}
