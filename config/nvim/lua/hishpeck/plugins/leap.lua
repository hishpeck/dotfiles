return {
	url = "https://codeberg.org/andyg/leap.nvim",
	priority = 100,
	config = function()
		vim.keymap.set("n", "<leader>l", function()
			require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
		end)
	end,
}
