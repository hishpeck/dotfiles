return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		image = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		lazygit = { enabled = true },
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
			"<leader>gg",
			function()
				Snacks.lazygit.open()
			end,
			desc = "Open Lazygit",
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
		require("snacks").setup(opts)

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
