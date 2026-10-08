return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local keymap = vim.keymap -- for conciseness

		-- Define the on_attach function to apply keymaps and settings to each LSP client
		local opts = { noremap = true, silent = true }
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			-- set keybinds
			opts.desc = "Show LSP references"
			keymap.set("n", "gr", function()
				Snacks.picker.lsp_references()
			end, opts)

			opts.desc = "Show LSP references to the current file"
			keymap.set("n", "gR", function()
				local component_name = vim.fn.expand("%:t:r")
				Snacks.picker.grep_word({ search = component_name })
			end, opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", function()
				Snacks.picker.lsp_definitions()
			end, opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", function()
				Snacks.picker.lsp_implementations()
			end, opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", function()
				Snacks.picker.lsp_type_definitions()
			end, opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		-- Get default capabilities for autocompletion
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			-- Show the message of the diagnostic that `[d`/`]d` jumps to
			jump = {
				on_jump = function(diagnostic, bufnr)
					if diagnostic then
						vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
					end
				end,
			},
		})

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
			"phpantom_lsp",
			"laravel_lsp",
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
			elseif server_name == "tailwindcss" then
				server_opts.filetypes = {
					"css", "scss", "sass", "postcss",
					"html", "blade", "php",
					"javascript", "javascriptreact", "typescript", "typescriptreact",
					"vue", "svelte", "astro",
				}
				server_opts.root_dir = function(bufnr, cb)
					-- v3: traditional JS config files
					local v3_root = vim.fs.root(bufnr, {
						"tailwind.config.js",
						"tailwind.config.ts",
						"tailwind.config.cjs",
						"tailwind.config.mjs",
						"postcss.config.js",
						"postcss.config.ts",
					})
					if v3_root then
						cb(v3_root)
						return
					end
					-- v4: nearest package.json that has @tailwindcss/* dependencies
					local fname = vim.api.nvim_buf_get_name(bufnr)
					local pkg = vim.fs.find("package.json", {
						path = vim.fs.dirname(fname),
						upward = true,
						stop = vim.env.HOME,
					})[1]
					if pkg then
						local ok, lines = pcall(vim.fn.readfile, pkg)
						if ok and table.concat(lines, ""):find('"@tailwindcss/') then
							cb(vim.fs.dirname(pkg))
						end
					end
				end
				server_opts.settings = {
					tailwindCSS = {
						files = {
							exclude = {
								"**/.git/**",
								"**/node_modules/**",
								"**/vendor/**",
								"**/storage/**",
								"**/bootstrap/cache/**",
								"**/public/build/**",
							},
						},
					},
				}
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
			elseif server_name == "laravel_lsp" then
				-- Projects run MySQL in Docker with DB_HOST=database, which only resolves inside
				-- the container network; the LSP runs host PHP, so point it at the published port
				server_opts.cmd_env = { DB_HOST = "127.0.0.1" }
				server_opts.before_init = function(params, config)
					-- Prefer the project's Docker wrapper (e.g. carandclassic's bin/car) so scripts
					-- run with the container's PHP, extensions and database host
					local car = config.root_dir and config.root_dir .. "/bin/car"
					if car and vim.fn.executable(car) == 1 then
						params.initializationOptions = { phpCommand = { car, "php" } }
					else
						-- The model index script exceeds PHP's default 128M on large apps and exits silently
						params.initializationOptions = { phpCommand = { "php", "-d", "memory_limit=-1" } }
					end
				end
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
