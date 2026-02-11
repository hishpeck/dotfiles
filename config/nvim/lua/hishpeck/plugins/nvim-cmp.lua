return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths
			"onsails/lspkind.nvim", -- vs-code like icons for autocompletion
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"hrsh7th/cmp-nvim-lua", -- neovim Lua API
			"zbirenbaum/copilot-cmp", -- autocompletion for Copilot
			"nvim-treesitter/nvim-treesitter", -- for treesitter context in cmp
			-- "kristijanhusak/vim-dadbod-completion",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			local function is_in_start_tag()
				local node = vim.treesitter.get_node()
				if not node then
					return false
				end

				local node_type = node:type()
				local target_nodes = { "start_tag", "self_closing_tag", "directive_attribute" }

				local is_tag = vim.tbl_contains(target_nodes, node_type)
				if not is_tag and node:parent() then
					is_tag = vim.tbl_contains(target_nodes, node:parent():type())
				end

				return is_tag
			end

			vim.api.nvim_create_autocmd("CursorMovedI", {
				pattern = "*.vue",
				callback = function()
					vim.b.vue_ts_cached_is_in_start_tag = nil
				end,
			})

			-- load vs-code like snippets from plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			luasnip.config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
			})

			luasnip.filetype_extend("php", { "blade" })

			require("copilot_cmp").setup()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
					["<C-e>"] = cmp.mapping.abort(), -- close completion window
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),

				sources = cmp.config.sources({
					{ name = "copilot" }, -- copilot
					{
						name = "nvim_lsp",
						---@param entry cmp.Entry
						---@param ctx cmp.Context
						entry_filter = function(entry, ctx)
							if ctx.filetype ~= "vue" then
								return true
							end

							if vim.b.vue_ts_cached_is_in_start_tag == nil then
								vim.b.vue_ts_cached_is_in_start_tag = is_in_start_tag()
							end

							if not vim.b.vue_ts_cached_is_in_start_tag then
								return true
							end

							local cursor_before_line = ctx.cursor_before_line
							local last_char = cursor_before_line:sub(-1)

							if last_char == "@" then
								return entry.completion_item.label:match("^@")
							elseif last_char == ":" then
								return entry.completion_item.label:match("^:")
									and not entry.completion_item.label:match("^:on%-")
							else
								return true
							end
						end,
					}, -- lsp
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
					{ name = "nvim_lua" }, -- neovim api
				}),

				-- configure lspkind for vs-code like icons
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
						symbol_map = { Copilot = "" },
					}),
				},

				experimental = {
					ghost_text = true,
				},
			})

			-- cmp.setup.filetype({
			-- 	"sql",
			-- 	{
			-- 		sources = {
			-- 			{ name = "vim-dadbod-completion" },
			-- 			{ name = "luasnip" },
			-- 			{ name = "buffer" },
			-- 		},
			-- 	},
			-- })

			vim.keymap.set({ "i", "s" }, "<C-h>", function()
				if luasnip.jumpable(-1) then
					luasnip.jump(-1)
				end
			end, { silent = true, desc = "Go to the next snippet section" })
			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				if luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { silent = true, desc = "Go to the previous snippet section" })
			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(1)
				end
			end, { silent = true, desc = "Choose next snippet choice" })
			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if luasnip.choice_active() then
					luasnip.change_choice(-1)
				end
			end, { silent = true, desc = "Choose previous snippet choice" })
		end,
	},
}
