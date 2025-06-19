return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "f-person/git-blame.nvim" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local git_blame = require("gitblame")
		vim.g.gitblame_display_virtual_text = 0
		vim.g.gitblame_date_format = "%x"
		vim.g.gitblame_max_commit_summary_length = 25

		lualine.setup({
			options = {
				theme = "catppuccin",
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(0, 1)
						end,
					},
				},
				lualine_b = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_c = {
					{
						git_blame.get_current_blame_text,
						cond = git_blame.is_blame_text_available,
						padding = 0,
						color = {
							fg = "#7C7F93",
							gui = "italic",
						},
					},
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_y = {
					{
						"branch",
						fmt = function(str)
							return str:sub(0, 7)
						end,
					},
				},
				lualine_z = {
					{ "progress" },
				},
			},
		})
	end,
}
