return {
	"nvim-lualine/lualine.nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		lualine.setup({
			options = {
				theme = "catppuccin-nvim",
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
						function()
							return vim.b.gitsigns_blame_line
						end,
						cond = function()
							return vim.b.gitsigns_blame_line ~= nil
						end,
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
							return str:sub(0, 8)
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
