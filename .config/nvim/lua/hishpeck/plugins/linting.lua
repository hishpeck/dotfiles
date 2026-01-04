return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		local phpstan = require("lint").linters.phpstan
		phpstan.args = {
			"analyze",
			"--error-format=json",
			"--no-progress",
			"--memory-limit=2G",
		}

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			vue = { "eslint_d" },
			glsl = { "glslc" },
			-- php = { "phpstan" },
			go = { "golangcilint" },
		}

		-- Function to find the project root by searching for a marker file
		local function find_project_root(file_path)
			local start_dir = vim.fs.dirname(file_path)
			local root_markers = { "package.json", ".git", "eslint.config.js", ".eslintrc.js" }
			local project_root = vim.fs.find(root_markers, { path = start_dir, upward = true, stop = vim.env.HOME })[1]
			return project_root and vim.fs.dirname(project_root) or start_dir
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePre" }, {
			group = lint_augroup,
			callback = function(args)
				local linter_args = {}
				if args.buf then
					local file_path = vim.api.nvim_buf_get_name(args.buf)
					if file_path and file_path ~= "" then
						linter_args.cwd = find_project_root(file_path)
					end
				end
				lint.try_lint(nil, linter_args)
			end,
		})

		vim.keymap.set("n", "<leader>L", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
