return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			provider = "openrouter",
			-- Disabled due to MCP Hub integration
			disabled_tools = {
				"list_files", -- Built-in file operations
				"search_files",
				"read_file",
				"create_file",
				"rename_file",
				"delete_file",
				"create_dir",
				"rename_dir",
				"delete_dir",
				"bash", -- Built-in terminal access
			},
			providers = {
				deepseek = {
					__inherited_from = "openai",
					api_key_name = "DEEPSEEK_API_KEY",
					endpoint = "https://api.deepseek.com",
					model = "deepseek-coder",
				},
				gemini = {
					model = "gemini-2.5-flash",
				},
				claude = {
					endpoint = "https://api.anthropic.com",
					model = "claude-sonnet-4-20250514",
					timeout = 30000, -- Timeout in milliseconds
					extra_request_body = {
						temperature = 0.75,
						max_tokens = 20480,
					},
				},
				openrouter = {
					__inherited_from = "openai",
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "minimax/minimax-m2",
				},
			},
			file_selector = { provider = "telescope" },
			system_prompt = function()
				local hub = require("mcphub").get_hub_instance()
				local prompt = hub and hub:get_active_servers_prompt() or ""
				local guidelines_path = vim.fn.stdpath("config") .. "/.junie/guidelines.md"
				local guidelines_file = io.open(guidelines_path, "r")
				if guidelines_file then
					local guidelines_content = guidelines_file:read("*a")
					io.close(guidelines_file)
					prompt = prompt .. "\\\\n\\\\n# Project Guidelines\\\\n" .. guidelines_content
				end
				return prompt
			end,
			custom_tools = function()
				return {
					require("mcphub.extensions.avante").mcp_tool(),
				}
			end,
		},
		build = "make",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim",
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"ravitemer/mcphub.nvim",
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = "bundled_build.lua", -- Bundles `mcp-hub` binary along with the neovim plugin
		config = function()
			require("mcphub").setup({
				use_bundled_binary = true, -- Use local `mcp-hub` binary
				auto_approve = true,
				extensions = {
					avante = {
						make_slash_commands = true, -- make /slash commands from MCP server prompts
					},
				},
			})
		end,
	},
}
