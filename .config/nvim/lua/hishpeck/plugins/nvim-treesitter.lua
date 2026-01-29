return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
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

			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.blade = {
				install_info = {
					url = "https://github.com/EmranMR/tree-sitter-blade",
					files = { "src/parser.c" },
					branch = "main",
				},
				filetype = "blade",
			}

			-- import nvim-treesitter plugin
			local treesitter = require("nvim-treesitter.configs")

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
				textobjects = {
					-- lsp_interop = {
					-- 	enable = true,
					-- 	border = "none",
					-- 	floating_preview_opts = {},
					-- 	peek_definition_code = {
					-- 		["<leader>df"] = "@function.outer",
					-- 		["<leader>dF"] = "@class.outer",
					-- 	},
					-- },
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
							["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
							["ak"] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
							["av"] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

							["a:"] = { query = "@property.outer", desc = "Select outer property/key-value" },
							["i:"] = { query = "@property.inner", desc = "Select inner property/key-value" },

							["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
							["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

							-- 	["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
							-- 	["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

							-- 	["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
							-- 	["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

							["af"] = { query = "@function.outer", desc = "Select outer part of a function call" },
							["if"] = { query = "@function.inner", desc = "Select inner part of a function call" },

							-- ["am"] = {
							-- 	query = "@function.outer",
							-- 	desc = "Select outer part of a method/function definition",
							-- },
							-- ["im"] = {
							-- 	query = "@function.inner",
							-- 	desc = "Select inner part of a method/function definition",
							-- },

							-- ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
							-- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
							["<leader>n:"] = "@property.outer", -- swap object property with next
							["<leader>nm"] = "@function.outer", -- swap function with next
						},
						swap_previous = {
							["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
							["<leader>p:"] = "@property.outer", -- swap object property with prev
							["<leader>pm"] = "@function.outer", -- swap function with previous
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]f"] = { query = "@call.outer", desc = "Next function call start" },
							["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
							["]c"] = { query = "@class.outer", desc = "Next class start" },
							["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
							["]l"] = { query = "@loop.outer", desc = "Next loop start" },

							-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
							-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
							["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
							["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
						},
						goto_next_end = {
							["]F"] = { query = "@call.outer", desc = "Next function call end" },
							["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
							["]C"] = { query = "@class.outer", desc = "Next class end" },
							["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
							["]L"] = { query = "@loop.outer", desc = "Next loop end" },
						},
						goto_previous_start = {
							["[f"] = { query = "@call.outer", desc = "Prev function call start" },
							["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
							["[c"] = { query = "@class.outer", desc = "Prev class start" },
							["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
							["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
						},
						goto_previous_end = {
							["[F"] = { query = "@call.outer", desc = "Prev function call end" },
							["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
							["[C"] = { query = "@class.outer", desc = "Prev class end" },
							["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
							["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
						},
					},
				},
			})

			-- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
			require("ts_context_commentstring").setup({})

			require("treesitter-context").setup({})
		end,
	},
}
