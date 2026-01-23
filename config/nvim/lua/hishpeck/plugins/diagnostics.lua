return {
	"ivanjermakov/troublesum.nvim",
	event = "VeryLazy",
	opts = {
		display_summary = function(bufnr, ns, text)
			local line = vim.fn.line("w$") - 1
			vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
				virt_text = text,
				virt_text_pos = "right_align",
			})
		end,
	},
}
