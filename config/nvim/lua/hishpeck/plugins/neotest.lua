return {
	"nvim-neotest/neotest",
	keys = {
		{ "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
		{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run all tests in the current file" },
		{ "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test results summary" },
		{ "<leader>tr", function() require("neotest").output.open() end, desc = "Open test output" },
	},
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
				enabled = true,
				open = false,
			},
			diagnostic = {
				enabled = true,
			},
			signs = {
				enabled = true,
				passed = {
					text = "✔",
				},
				running = {
					text = "⟳",
				},
				failed = {
					text = "✖",
				},
				skipped = {
					text = "ﰸ",
				},
			},
		})
	end,
}
