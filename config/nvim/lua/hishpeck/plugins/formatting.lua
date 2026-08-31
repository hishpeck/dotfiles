return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Projects that ship oxfmt (node_modules/.bin/oxfmt + an .oxfmtrc.json/oxfmt.config.ts
		-- above the buffer) use it in place of prettier, so formatting matches what their
		-- lint-staged/CI pipeline actually applies.
		local function oxfmt_or_prettier(bufnr)
			if conform.get_formatter_info("oxfmt", bufnr).available then
				return { "oxfmt" }
			end
			return { "prettier" }
		end

		conform.setup({
			formatters_by_ft = {
				javascript = oxfmt_or_prettier,
				typescript = oxfmt_or_prettier,
				javascriptreact = oxfmt_or_prettier,
				typescriptreact = oxfmt_or_prettier,
				vue = oxfmt_or_prettier,
				css = oxfmt_or_prettier,
				json = oxfmt_or_prettier,
				yaml = oxfmt_or_prettier,
				markdown = oxfmt_or_prettier,
				-- oxfmt doesn't format these reliably (svelte is a no-op passthrough) and
				-- carandclassic's own lint-staged config doesn't run oxfmt on them either.
				svelte = { "prettier" },
				html = { "prettier" },
				graphql = { "prettier" },
				lua = { "stylua" },
				php = { "php_cs_fixer" },
				blade = { "prettier" },
				rust = { "rustfmt" },
				go = { "goimports" },
				nix = { "nixfmt" },
			},
			format_after_save = {
				lsp_fallback = true,
			},
		})

		conform.formatters["blade-formatter"] = {
			args = { "--stdin", "--wrap-atts=preserve" },
		}

		vim.keymap.set({ "n", "v" }, "<leader>lf", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
