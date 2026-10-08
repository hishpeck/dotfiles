return {
	{
		-- Add the blade-nav.nvim plugin which provides Goto File capabilities
		-- for Blade files.
		"ricardoramirezr/blade-nav.nvim",
		ft = { "blade", "php" },
		opts = {
			integrations = {
				cmp = false, -- completion comes from its blink.cmp source instead
			},
		},
		config = function(_, opts)
			-- The plugin's ftplugin runs setup() itself once it detects a Laravel project,
			-- so only seed the config it will read rather than setting it up twice
			require("blade-nav.core.config").setup(opts)
		end,
	},
}
