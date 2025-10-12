return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"V13Axel/neotest-pest",
		"olimorris/neotest-phpunit",
		"marilari88/neotest-vitest",
	},
	config = function()
		local function find_project_root()
			local start_dir = vim.fn.expand("%:p:h")
			local root_markers = { "package.json", ".git", "eslint.config.js", ".eslintrc.js" }
			local project_root = vim.fs.find(root_markers, { path = start_dir, upward = true, stop = vim.env.HOME })[1]
			return project_root and vim.fs.dirname(project_root) or start_dir
		end

		require("neotest").setup({
			adapters = {
				-- require("neotest-pest")({
				-- 	-- parallel = function()
				-- 	-- 	return #vim.loop.cpu_info()
				-- 	-- end,
				-- }),
				require("neotest-phpunit")({
					filter_dirs = { "vendor" },
				}),
				require("neotest-vitest")({
					cwd = find_project_root(),
					filter_dir = function(name, rel_path, root)
						return name ~= "node_modules"
					end,
				}),
			},
			quickfix = {
				enabled = true, -- This opens the quickfix window for test failures.
				open = false, -- Don't auto-open quickfix window.
			},
			diagnostic = {
				enabled = true, -- Enable Neovim LSP diagnostics
			},
			signs = {
				enabled = true, -- Enable signs for test statuses
				passed = {
					text = "✔", -- Customize for a passed test (green checkmark)
				},
				running = {
					text = "⟳", -- Customize for a running test (spinning symbol)
				},
				failed = {
					text = "✖", -- Customize for a failed test (red cross)
				},
				skipped = {
					text = "ﰸ", -- Customize for a skipped test
				},
			},
		})

		vim.keymap.set("n", "<leader>tt", function()
			require("neotest").run.run()
		end, { desc = "Run nearest test" })
		vim.keymap.set("n", "<leader>tf", function()
			require("neotest").run.run(vim.fn.expand("%"))
		end, { desc = "Run all tests in the current file" })
		vim.api.nvim_set_keymap(
			"n",
			"<leader>ts",
			"<cmd>lua require('neotest').summary.toggle()<CR>",
			{ desc = "Toggle test results summary" }
		)
		vim.api.nvim_set_keymap("n", "<leader>tr", "<cmd>lua require('neotest').output.open()<cr>", {
			desc = "Open test output",
		})
	end,
}
