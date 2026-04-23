return {
	"catppuccin/nvim", -- colorscheme
	priority = 1000,
	config = function()
		local flavor = _G.catppuccin_flavor or "latte"
		local accent = _G.catppuccin_accent or "pink"

		require("catppuccin").setup({
			background = {
				light = "latte",
				dark = "frappe",
			},
			-- Use the flavor from nix if available
			flavour = flavor,
			dim_inactive = {
				-- enabled = true,
			},
			-- transparent_background = true,
			color_overrides = {
				latte = {
					crust = "#474747",
				},
			},
			integrations = {
				alpha = true,
				cmp = true,
				dap = true,
				dap_ui = true,
				gitsigns = true,
				leap = true,
				mason = true,
				notify = true,
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
					inlay_hints = {
						background = true,
					},
				},
			indent_blankline = {
				enabled = true,
				scope_color = accent,
					colored_indent_levels = false,
				},
				nvimtree = true,
				neotest = true,
				telescope = {
					enabled = true,
				},
				which_key = true,
			},
		})

		vim.cmd([[colorscheme catppuccin]])
		if flavor == "latte" then
			vim.opt.background = "light"
		else
			vim.opt.background = "dark"
		end
	end,
}
