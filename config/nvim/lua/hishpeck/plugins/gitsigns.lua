return {
	"lewis6991/gitsigns.nvim", -- show line modifications on left hand side
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		-- blame is shown in lualine instead of as virtual text
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = false,
			delay = 1000,
		},
		current_line_blame_formatter = function(_, blame_info)
			local summary = blame_info.summary
			if #summary > 25 then
				summary = summary:sub(1, 25) .. "..."
			end
			local date = os.date("%x", tonumber(blame_info.author_time))
			return { { ("%s • %s • %s"):format(summary, date, blame_info.author), "GitSignsCurrentLineBlame" } }
		end,
	},
}
