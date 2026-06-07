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
		scroll = { enabled = true },
		words = { enabled = true },
		picker = {
			ui_select = true,
		},
	},
	keys = {
		{
			"<leader>.",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
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
