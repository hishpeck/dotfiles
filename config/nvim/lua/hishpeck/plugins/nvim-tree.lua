return {
	"nvim-tree/nvim-tree.lua",
	cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeCollapse", "NvimTreeRefresh" },
	keys = {
		{ "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
		{ "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Toggle file explorer on current file" },
		{ "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "Collapse file explorer" },
		{ "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file explorer" },
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	init = function()
		-- must be set before netrw loads
		vim.g.loaded = 1
		vim.g.loaded_netrwPlugin = 1
	end,
	config = function()
		local nvimtree = require("nvim-tree")

		nvimtree.setup({
			filesystem_watchers = {
				ignore_dirs = { ".git", "node_modules", "vendor" },
			},
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
				timeout = 2000,
			},
		})
	end,
}
