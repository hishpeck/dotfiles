return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
			},
			"windwp/nvim-ts-autotag",
			"JoosepAlviste/nvim-ts-context-commentstring",
			"nvim-treesitter/nvim-treesitter-context",
			-- "filNaj/tree-setter",
		},
		config = function()
			vim.filetype.add({
				pattern = {
					[".*%.blade%.php"] = "blade",
				},
			})

			-- import nvim-treesitter plugin
			local treesitter = require("nvim-treesitter.config")

			-- configure treesitter
			treesitter.setup({ -- enable syntax highlighting
				highlight = {
					enable = true,
				},
				-- enable indentation
				indent = { enable = true },
				-- enable autotagging (w/ nvim-ts-autotag plugin)
				autotag = {
					enable = true,
				},
				-- tree_setter = {
				-- 	enable = true,
				-- },
				-- ensure these language parsers are installed
				ensure_installed = {
					"json",
					"javascript",
					"typescript",
					"tsx",
					"yaml",
					"html",
					"css",
					"markdown",
					"markdown_inline",
					"graphql",
					"bash",
					"lua",
					"vim",
					"dockerfile",
					"gitignore",
					"astro",
					"jsdoc",
					"php",
					"phpdoc",
					"rust",
					"tmux",
					"vue",
					"sql",
					"glsl",
					"blade",
					"twig",
					"go",
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>>",
						node_incremental = ">",
						scope_incremental = false,
						node_decremental = "<",
					},
				},
			})

			require("ts_context_commentstring").setup({})

			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select_maps = {
				["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
				["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
				["ak"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
				["av"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
				["a:"] = { query = "@property.outer", desc = "Select outer property/key-value" },
				["i:"] = { query = "@property.inner", desc = "Select inner property/key-value" },
				["aa"] = { query = "@parameter.outer", desc = "Select outer parameter/argument" },
				["ia"] = { query = "@parameter.inner", desc = "Select inner parameter/argument" },
				["af"] = { query = "@function.outer", desc = "Select outer part of a function call" },
				["if"] = { query = "@function.inner", desc = "Select inner part of a function call" },
			}

			for key, map in pairs(select_maps) do
				vim.keymap.set({ "x", "o" }, key, function()
					require("nvim-treesitter-textobjects.select").select_textobject(map.query, "textobjects")
				end, { desc = map.desc })
			end

			local swap_next = {
				["<leader>na"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
				["<leader>n:"] = { query = "@property.outer", desc = "Swap object property with next" },
				["<leader>nm"] = { query = "@function.outer", desc = "Swap function with next" },
			}
			for key, map in pairs(swap_next) do
				vim.keymap.set("n", key, function()
					require("nvim-treesitter-textobjects.swap").swap_next(map.query)
				end, { desc = map.desc })
			end

			local swap_prev = {
				["<leader>pa"] = { query = "@parameter.inner", desc = "Swap parameter with prev" },
				["<leader>p:"] = { query = "@property.outer", desc = "Swap object property with prev" },
				["<leader>pm"] = { query = "@function.outer", desc = "Swap function with prev" },
			}
			for key, map in pairs(swap_prev) do
				vim.keymap.set("n", key, function()
					require("nvim-treesitter-textobjects.swap").swap_previous(map.query)
				end, { desc = map.desc })
			end
		end,
	},
}
