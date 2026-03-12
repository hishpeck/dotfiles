return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		branch = "main", -- Welcome to the cutting edge
		build = ":TSUpdate",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main", -- Textobjects must also track main
			},
			"windwp/nvim-ts-autotag",
			"JoosepAlviste/nvim-ts-context-commentstring",
			"nvim-treesitter/nvim-treesitter-context",
		},
		init = function()
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
		config = function()
			vim.filetype.add({
				pattern = {
					[".*%.blade%.php"] = "blade",
				},
			})

			local parsers = {
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
				"vimdoc",
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
			}
			require("nvim-treesitter").install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
				callback = function(args)
					local buf = args.buf
					pcall(vim.treesitter.start, buf)

					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})

			-- 4. Setup External Dependencies natively
			require("ts_context_commentstring").setup({})
			require("nvim-ts-autotag").setup({}) -- Autotag now requires its own setup call

			-- 5. Setup Textobjects
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			-- 6. Textobject Keymaps
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
