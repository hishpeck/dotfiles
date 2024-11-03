return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-smart-history.nvim",
		"kkharji/sqlite.lua",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "truncate " },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						-- ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-Down>"] = actions.cycle_history_next,
						["<C-Up>"] = actions.cycle_history_prev,
					},
				},
				history = {
					path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
					limit = 100,
				},
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("notify")
		telescope.load_extension("smart_history")

		-- utility function to check if nvim-tree is focused and get current directory
		local function get_nvim_tree_dir()
			local core = require("nvim-tree.core")
			local view = require("nvim-tree.view")
			if view.is_visible() and vim.api.nvim_get_current_win() == view.get_winnr() then
				local node = core.get_explorer():get_node_at_cursor()
				if node then
					return node.absolute_path
				end
			end
			return nil
		end

		-- keymap utility to call telescope with dynamic directory
		local function telescope_find_files()
			local nvim_tree_dir = get_nvim_tree_dir()
			if nvim_tree_dir then
				require("telescope.builtin").find_files({ cwd = nvim_tree_dir })
			else
				require("telescope.builtin").find_files()
			end
		end

		local function telescope_live_grep()
			local nvim_tree_dir = get_nvim_tree_dir()
			if nvim_tree_dir then
				require("telescope.builtin").live_grep({ cwd = nvim_tree_dir })
			else
				require("telescope.builtin").live_grep()
			end
		end

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		-- keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		-- keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set(
			"n",
			"<leader>ff",
			telescope_find_files,
			{ desc = "Fuzzy find files in current directory or project" }
		)
		keymap.set("n", "<leader>fs", telescope_live_grep, { desc = "Find string in current directory or project" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })
		keymap.set(
			"n",
			"<leader>fw",
			"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
			{ desc = "Fuzzy find project symbols" }
		)
		keymap.set(
			"n",
			"<leader>fd",
			"<cmd>Telescope lsp_document_symbols<cr>",
			{ desc = "Fuzzy find document symbols" }
		)
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set(
			"n",
			"<leader>fb",
			"<cmd>Telescope buffers<cr>",
			{ desc = "Fuzzy find open buffers in current neovim instance" }
		)
		keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Fuzzy find available help tags" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
	end,
}
