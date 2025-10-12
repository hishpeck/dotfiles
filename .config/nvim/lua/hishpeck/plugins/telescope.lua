return {
	"nvim-telescope/telescope.nvim",
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
				path_display = { "truncate" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						-- ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						["<C-PageDown>"] = actions.cycle_history_next,
						["<C-PageUp>"] = actions.cycle_history_prev,
						["<C-Up>"] = actions.preview_scrolling_up,
						["<C-Down>"] = actions.preview_scrolling_down,
						["<C-Left>"] = actions.preview_scrolling_left,
						["<C-Right>"] = actions.preview_scrolling_right,
					},
				},
				history = {
					path = vim.fn.stdpath("cache") .. "/telescope_history.sqlite3",
					limit = 100,
				},
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
			extensions = {
				fzf = {},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("notify")
		telescope.load_extension("smart_history")

		-- utility function to check if nvim-tree is focused and get current directory
		local function get_nvim_tree_dir()
			local api = require("nvim-tree.api")

			-- Get the current buffer number
			local current_buf = vim.api.nvim_get_current_buf()

			-- Check if the buffer is an nvim-tree buffer and the tree is visible
			if api.tree.is_visible() and api.tree.is_tree_buf(current_buf) then
				local node = api.tree.get_node_under_cursor()
				if node then
					-- For a directory, return its path. For a file, return its parent directory.
					if node.type == "directory" then
						return node.absolute_path
					else
						return vim.fn.fnamemodify(node.absolute_path, ":h")
					end
				end
			end

			-- Fallback to the current working directory if nvim-tree isn't focused
			return vim.fn.getcwd()
		end

		local function telescope_call_method(name)
			return function()
				local builtin = require("telescope.builtin")

				if not builtin[name] then
					print("Telescope method '" .. name .. "' not found.")
					return
				end

				local nvim_tree_dir = get_nvim_tree_dir()

				if nvim_tree_dir then
					builtin[name]({ cwd = nvim_tree_dir })
				else
					builtin[name]()
				end
			end
		end

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set(
			"n",
			"<leader>ff",
			telescope_call_method("find_files"),
			{ desc = "Fuzzy find files in current directory or project" }
		)
		keymap.set(
			"n",
			"<leader>fs",
			telescope_call_method("live_grep"),
			{ desc = "Find string in current directory or project" }
		)
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find recent files" })
		keymap.set(
			"n",
			"<leader>fw",
			telescope_call_method("lsp_dynamic_workspace_symbols"),
			{ desc = "Fuzzy find project symbols" }
		)
		keymap.set(
			"n",
			"<leader>fd",
			telescope_call_method("lsp_document_symbols"),
			{ desc = "Fuzzy find document symbols" }
		)
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set(
			"n",
			"<leader>fb",
			telescope_call_method("buffers"),
			{ desc = "Fuzzy find open buffers in current neovim instance" }
		)
		keymap.set("n", "<leader>fh", telescope_call_method("help_tags"), { desc = "Fuzzy find available help tags" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
	end,
}
