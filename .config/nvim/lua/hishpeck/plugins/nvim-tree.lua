return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			renderer = {
				icons = {
					git_placement = "signcolumn",
					glyphs = {
						git = {
							unstaged = "U",
							staged = "S",
							unmerged = "UM",
							renamed = "R",
							deleted = "D",
							untracked = "UT",
							ignored = "I",
						},
					},
				},
			},
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
					quit_on_open = true,
				},
			},
			git = {
				ignore = false,
			},
		})

		-- keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		)
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
	end,
}
