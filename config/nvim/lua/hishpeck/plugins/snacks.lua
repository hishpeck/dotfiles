-- Snacks.scroll animates from the cursor's real column, which on a short line is the line end
-- rather than the virtual column the preview parks it on, so it would replay every vertical
-- scroll from the left edge. Preview windows are animated by preview_scroll below instead.
local function is_picker_preview(buf)
	if not package.loaded["snacks.picker"] then
		return false
	end
	for _, picker in ipairs(Snacks.picker.get()) do
		local win = picker.preview and picker.preview.win.win
		if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
			return true
		end
	end
	return false
end

-- Scrolls the picker preview half a screen in either direction, animated like Snacks.scroll.
-- Sets leftcol directly because `zl` stops short on tab-indented lines, hiding the end of the
-- longest visible line
local function preview_scroll(picker, dx, dy)
	local win = picker.preview.win.win
	if not (win and vim.api.nvim_win_is_valid(win)) then
		return
	end

	-- Move the view and park the hidden cursor on its top-left corner; the window's
	-- virtualedit=all lets it sit past short lines so it never drags the view back
	local function set_view(topline, leftcol)
		vim.api.nvim_win_call(win, function()
			vim.cmd(("keepjumps normal! %dG%d|"):format(topline, leftcol + 1))
			vim.fn.winrestview({ topline = topline, leftcol = leftcol })
		end)
	end

	vim.api.nvim_win_call(win, function()
		local view = vim.fn.winsaveview()
		-- step from the pending target so repeated presses during an animation add up
		local target = vim.w[win].preview_scroll_target or { view.topline, view.leftcol }
		local top, left = target[1], target[2]

		if dy ~= 0 then
			local height = vim.api.nvim_win_get_height(win)
			top = math.max(1, math.min(top + dy * math.floor(height / 2), vim.fn.line("$") - height + 1))
		end
		if dx ~= 0 then
			local text_width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
			local longest = 0
			for lnum = top, math.min(top + vim.api.nvim_win_get_height(win) - 1, vim.fn.line("$")) do
				longest = math.max(longest, vim.fn.virtcol({ lnum, "$" }) - 1)
			end
			left = math.max(0, math.min(left + dx * math.floor(text_width / 2), longest - text_width))
		end
		vim.w[win].preview_scroll_target = { top, left }

		local from_top, from_left = view.topline, view.leftcol
		Snacks.animate(0, 100, function(value, ctx)
			if not vim.api.nvim_win_is_valid(win) then
				return
			end
			if ctx.done then
				vim.w[win].preview_scroll_target = nil
				return set_view(top, left)
			end
			set_view(
				math.floor(from_top + (top - from_top) * value / 100 + 0.5),
				math.floor(from_left + (left - from_left) * value / 100 + 0.5)
			)
		end, {
			int = true,
			id = "preview_scroll_" .. win,
			duration = { step = 10, total = 200 },
			easing = "linear",
		})
	end)
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		lazygit = {
			enabled = true,
			configure = true,
		},
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scratch = { enabled = true },
		scroll = {
			enabled = true,
			filter = function(buf)
				return vim.g.snacks_scroll ~= false
					and vim.b[buf].snacks_scroll ~= false
					and vim.bo[buf].buftype ~= "terminal"
					and not is_picker_preview(buf)
			end,
		},
		words = { enabled = true },
		explorer = { enabled = true },
		picker = {
			ui_select = true,
			-- nix has no global libsqlite3; the path is exported by the neovim wrapper
			db = { sqlite3_path = vim.env.LIBSQLITE },
			win = {
				input = {
					keys = {
						["<C-PageDown>"] = { "history_forward", mode = { "i", "n" } },
						["<C-PageUp>"] = { "history_back", mode = { "i", "n" } },
						["<C-Up>"] = { "preview_scroll_up", mode = { "i", "n" } },
						["<C-Down>"] = { "preview_scroll_down", mode = { "i", "n" } },
						["<C-Left>"] = { "preview_scroll_left", mode = { "i", "n" } },
						["<C-Right>"] = { "preview_scroll_right", mode = { "i", "n" } },
						["<ScrollWheelLeft>"] = { "preview_scroll_left", mode = { "i", "n" } },
						["<ScrollWheelRight>"] = { "preview_scroll_right", mode = { "i", "n" } },
						["<C-x>"] = { "edit_split", mode = { "i", "n" } },
					},
				},
				-- unwrapped so long lines can be scrolled horizontally; virtualedit lets the hidden
				-- cursor sit past short lines so it never drags the view back left
				preview = { wo = { wrap = false, virtualedit = "all" } },
			},
			actions = {
				-- replace the built-in preview scrolls: see preview_scroll above
				preview_scroll_up = function(picker)
					preview_scroll(picker, 0, -1)
				end,
				preview_scroll_down = function(picker)
					preview_scroll(picker, 0, 1)
				end,
				preview_scroll_left = function(picker)
					preview_scroll(picker, -1, 0)
				end,
				preview_scroll_right = function(picker)
					preview_scroll(picker, 1, 0)
				end,
			},
			sources = {
				files = { hidden = true },
				explorer = {
					hidden = true,
					ignored = true,
					jump = { close = true },
					actions = {
						picker_files = function(_, item)
							if item then
								Snacks.picker.files({ cwd = Snacks.picker.util.dir(item) })
							end
						end,
					},
					win = {
						list = {
							keys = {
								-- search from the directory under the cursor
								["<leader>ff"] = "picker_files",
								["<leader>fs"] = "picker_grep",
							},
						},
					},
				},
			},
		},
	},
	keys = {
		-- stylua: ignore start
		{ "<leader>ff", function() Snacks.picker.files() end, desc = "Fuzzy find files in cwd" },
		{ "<leader>fs", function() Snacks.picker.grep() end, desc = "Find string in cwd" },
		{ "<leader>fr", function() Snacks.picker.recent() end, desc = "Find recent files" },
		{ "<leader>fw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Fuzzy find project symbols" },
		{ "<leader>fd", function() Snacks.picker.lsp_symbols() end, desc = "Fuzzy find document symbols" },
		{ "<leader>fc", function() Snacks.picker.grep_word() end, desc = "Find string under cursor in cwd" },
		{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Fuzzy find open buffers" },
		{ "<leader>fh", function() Snacks.picker.help() end, desc = "Fuzzy find available help tags" },
		{ "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "Find todos" },
		-- stylua: ignore end
		{
			"<leader>ee",
			function()
				local explorer = Snacks.picker.get({ source = "explorer" })[1]
				if explorer then
					explorer:close()
				else
					Snacks.explorer()
				end
			end,
			desc = "Toggle file explorer",
		},
		{
			"<leader>ef",
			function()
				Snacks.explorer.reveal()
			end,
			desc = "Reveal current file in file explorer",
		},
		{
			"<leader>ec",
			function()
				local explorer = Snacks.picker.get({ source = "explorer" })[1]
				if explorer then
					explorer:action("explorer_close_all")
				end
			end,
			desc = "Collapse file explorer",
		},
		{
			"<leader>.",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>sm",
			function()
				Snacks.zen.zoom()
			end,
			desc = "Maximize/minimize a split",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Lazygit File Log",
		},
		{
			"<leader>nn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Show Notifications history",
		},
	},
	config = function(_, opts)
		local snacks = require("snacks")
		snacks.setup(opts)

		-- Track git branch for auto-session restore on lazygit close
		vim.g.last_git_branch = nil

		-- Function to check branch and restore session if changed
		local function check_and_restore_session()
			-- Only check if we're in a git repo
			if vim.fn.isdirectory(".git") == 0 then
				return
			end

			-- Get current branch
			local branch_cmd = vim.fn.system("git branch --show-current 2>/dev/null")
			if vim.v.shell_error ~= 0 then
				return
			end

			local current_branch = vim.trim(branch_cmd)
			if current_branch == "" then
				return
			end

			-- Initialize on first check
			if vim.g.last_git_branch == nil then
				vim.g.last_git_branch = current_branch
				return
			end

			-- Branch changed! Restore session
			if vim.g.last_git_branch ~= current_branch then
				local old_branch = vim.g.last_git_branch
				vim.g.last_git_branch = current_branch

				snacks.notifier.notify(string.format("Switched: %s → %s", old_branch, current_branch), "info", {
					title = " Branch Changed",
					icon = " ",
				})

				-- Restore session after a brief delay
				vim.defer_fn(function()
					local ok, err = pcall(function()
						require("auto-session").restore_session()
					end)

					if ok then
						snacks.notifier.notify("Session restored for branch: " .. current_branch, "info", {
							title = " Session Restored",
							icon = "󰦛 ",
						})
					else
						snacks.notifier.notify("Failed to restore session: " .. tostring(err), "warn", {
							title = " Session Restore Failed",
							icon = " ",
						})
					end
				end, 100)
			end
		end

		-- Track when lazygit is open
		vim.g.lazygit_is_open = false

		-- Override the lazygit keybinding to add our hook
		vim.keymap.set("n", "<leader>gg", function()
			-- Store branch before opening
			if vim.fn.isdirectory(".git") == 1 then
				local branch_cmd = vim.fn.system("git branch --show-current 2>/dev/null")
				if vim.v.shell_error == 0 then
					vim.g.last_git_branch = vim.trim(branch_cmd)
				end
			end

			-- Mark lazygit as open
			vim.g.lazygit_is_open = true

			-- Open lazygit
			snacks.lazygit.open()
		end, { desc = "Open Lazygit" })

		-- Listen for terminal/buffer close events to detect when lazygit closes
		vim.api.nvim_create_autocmd({ "TermClose", "BufWinLeave" }, {
			group = vim.api.nvim_create_augroup("LazygitSessionRestore", { clear = true }),
			callback = function(ev)
				-- Check if this was a lazygit terminal
				local bufname = vim.api.nvim_buf_get_name(ev.buf)
				if bufname:match("lazygit") and vim.g.lazygit_is_open then
					vim.g.lazygit_is_open = false
					-- Check for branch changes after lazygit closes
					vim.defer_fn(check_and_restore_session, 300)
				end
			end,
		})

		---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
		local progress = vim.defaulttable()

		vim.api.nvim_create_autocmd("LspProgress", {
			callback = function(ev)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local value = ev.data.params.value
				if not client or type(value) ~= "table" then
					return
				end

				local p = progress[client.id]

				for i = 1, #p + 1 do
					if i == #p + 1 or p[i].token == ev.data.params.token then
						p[i] = {
							token = ev.data.params.token,
							msg = ("[%3d%%] %s%s"):format(
								value.kind == "end" and 100 or value.percentage or 100,
								value.title or "",
								value.message and (" **%s**"):format(value.message) or ""
							),
							done = value.kind == "end",
						}
						break
					end
				end

				local msg = {}
				progress[client.id] = vim.tbl_filter(function(v)
					return table.insert(msg, v.msg) or not v.done
				end, p)

				local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

				Snacks.notifier.notify(table.concat(msg, "\n"), "info", {
					id = "lsp_progress",
					title = client.name,
					opts = function(notif)
						notif.icon = #progress[client.id] == 0 and " "
							or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
					end,
				})
			end,
		})
	end,
}
