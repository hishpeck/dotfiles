return {
	"kevinhwang91/nvim-bqf",
	event = "VeryLazy",
	opts = {
		auto_enable = true,
		auto_resize_height = true,
		preview = {
			win_height = 12,
			win_vheight = 12,
			delay_syntax = 80,
			border_chars = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
			should_preview_cb = function(bufnr, _)
				return vim.api.nvim_buf_line_count(bufnr) > 5
			end,
		},
		func_map = {
			vsplit = "<C-v>",
			split = "<C-x>",
			tabnew = "<C-t>",
		},
	},
}
