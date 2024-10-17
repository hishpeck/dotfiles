return {
	"rmagatti/auto-session",
	priority = 1001,
	lazy = false,
	config = function()
		local auto_session = require("auto-session")

		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

		auto_session.setup({
			auto_save_enabled = true,
			auto_restore_enabled = true,
			auto_session_use_git_branch = true,
			-- auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
			-- auto_session_allowed_dirs = { "~/projects/", "~/.config/" },
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
		keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory

		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				-- vim.notify("Saving session...")
				auto_session.SaveSession()
			end,
		})
	end,
}
