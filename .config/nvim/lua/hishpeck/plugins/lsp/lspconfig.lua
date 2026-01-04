return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap -- for conciseness

		-- Define the on_attach function to apply keymaps and settings to each LSP client
		local opts = { noremap = true, silent = true }
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			-- set keybinds
			opts.desc = "Show LSP references"
			keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		-- Get default capabilities for autocompletion
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- List of all servers to be configured and enabled
		local servers = {
			"html",
			"vtsls",
			"vue_ls",
			"cssls",
			"css_variables",
			"tailwindcss",
			"svelte",
			"prismals",
			"graphql",
			"emmet_ls",
			"astro",
			"intelephense",
			"phpactor",
			"pyright",
			"glsl_analyzer",
			"rust_analyzer",
			"gopls",
			"lua_ls",
		}

		-- Configure each server using vim.lsp.config()
		for _, server_name in ipairs(servers) do
			local server_opts = {
				on_attach = on_attach,
				capabilities = capabilities,
			}

			local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
			local vue_language_server_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
			local vue_plugin = {
				name = "@vue/typescript-plugin",
				location = vue_language_server_path,
				languages = { "vue" },
				configNamespace = "typescript",
			}

			-- Handle server-specific configurations
			if server_name == "vtsls" then
				server_opts.settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								vue_plugin,
							},
						},
					},
				}
				server_opts.filetypes = tsserver_filetypes
			elseif server_name == "ts_ls" then
				server_opts.init_options = {
					plugins = {
						vue_plugin,
					},
				}
				server_opts.filetypes = tsserver_filetypes
			elseif server_name == "svelte" then
				server_opts.on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							pcall(client.notify, "$/onDidChangeTsOrJsFile", { uri = ctx.file })
						end,
					})
				end
			elseif server_name == "graphql" then
				server_opts.filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" }
			elseif server_name == "emmet_ls" then
				server_opts.filetypes = {
					"html",
					"typescriptreact",
					"javascriptreact",
					"css",
					"sass",
					"scss",
					"less",
					"svelte",
					"vue",
					"blade.php",
				}
			elseif server_name == "phpactor" then
				-- local phpactor_phar = vim.fn.stdpath("data") .. "/mason/packages/phpactor/phpactor.phar"
				--
				-- server_opts.cmd = {
				-- 	"php",
				-- 	"-d",
				-- 	"memory_limit=2G",
				-- 	phpactor_phar,
				-- 	"language-server",
				-- }
				server_opts.cmd = { "phpactor", "language-server" }
				server_opts.root_markers = { "composer.json", ".git" }
				-- server_opts.on_attach = function(client, bufnr)
				-- 	on_attach(client, bufnr)
				--
				-- 	-- client.server_capabilities.completionProvider = false
				-- 	-- client.server_capabilities.hoverProvider = false
				-- 	-- client.server_capabilities.definitionProvider = false
				-- 	-- client.server_capabilities.referenceProvider = false
				-- end
			elseif server_name == "intelephense" then
				server_opts.settings = {
					intelephense = { compatibility = { preferPsalmPhpstanPrefixedAnnotations = true } },
				}
			elseif server_name == "lua_ls" then
				server_opts.settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				}
			end

			-- Register the configuration for the server
			vim.lsp.config(server_name, server_opts)
		end

		-- After all configurations are registered, enable them.
		-- This tells Neovim to automatically start these LSPs when appropriate.
		vim.lsp.enable(servers)
	end,
}
