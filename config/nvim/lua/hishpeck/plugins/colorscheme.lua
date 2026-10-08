local function get_cosmic_mode()
	local home = vim.env.HOME or os.getenv("HOME")
	if not home then
		return nil
	end

	-- COSMIC DE stores mode in ~/.config/cosmic/com.system76.CosmicTheme.Mode/{v2,v1}/is_dark
	for _, ver in ipairs({ "v2", "v1" }) do
		local path = string.format("%s/.config/cosmic/com.system76.CosmicTheme.Mode/%s/is_dark", home, ver)
		local f = io.open(path, "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content:find("true") then
				return "dark"
			elseif content:find("false") then
				return "light"
			end
		end
	end

	return nil
end

local function get_portal_mode()
	local handle = io.popen(
		"busctl --user call org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings Read ss 'org.freedesktop.appearance' 'color-scheme' 2>/dev/null"
	)
	if handle then
		local result = handle:read("*a")
		handle:close()
		if result:find("u 1") then
			return "dark"
		elseif result:find("u 2") or result:find("u 0") then
			return "light"
		end
	end
	return nil
end

local function get_target_mode()
	local mode = get_cosmic_mode() or get_portal_mode()
	if mode then
		return mode
	end

	-- Fallback to Nix configured flavor if mode cannot be detected
	local default_flavor = _G.catppuccin_flavor or "latte"
	return (default_flavor == "latte") and "light" or "dark"
end

return {
	"catppuccin/nvim", -- colorscheme
	priority = 1000,
	config = function()
		local accent = _G.catppuccin_accent or "peach"

		require("catppuccin").setup({
			background = {
				light = "latte",
				dark = "mocha",
			},
			flavour = "auto",
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
				blink_cmp = true,
				dap = true,
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
				neotest = true,
				snacks = {
					enabled = true,
				},
				which_key = true,
			},
		})

		local function sync_theme()
			local target_mode = get_target_mode()
			if vim.o.background ~= target_mode then
				vim.o.background = target_mode
				local ok, lualine = pcall(require, "lualine")
				if ok then
					package.loaded["lualine.themes.catppuccin-nvim"] = nil
					package.loaded["lualine.themes.catppuccin"] = nil
					pcall(lualine.setup, { options = { theme = "catppuccin-nvim" } })
				end
			end
		end

		local initial_mode = get_target_mode()
		vim.opt.background = initial_mode
		vim.cmd([[colorscheme catppuccin]])

		-- Sync via schedule and VimEnter to ensure any trailing init.lua code doesn't override it
		vim.schedule(sync_theme)
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = sync_theme,
		})

		-- Sync when Neovim regains window focus
		vim.api.nvim_create_autocmd("FocusGained", {
			callback = sync_theme,
		})

		-- Watch COSMIC theme setting file for real-time mode changes
		local uv = vim.uv or vim.loop
		local home = vim.env.HOME or os.getenv("HOME")
		if home and uv then
			for _, ver in ipairs({ "v2", "v1" }) do
				local dir = string.format("%s/.config/cosmic/com.system76.CosmicTheme.Mode/%s", home, ver)
				if vim.fn.isdirectory(dir) == 1 then
					local fs_event = uv.new_fs_event()
					if fs_event then
						fs_event:start(dir, {}, function(err, filename)
							if not err and (filename == nil or filename == "is_dark") then
								vim.schedule(sync_theme)
							end
						end)
					end
					break
				end
			end
		end
	end,
}
