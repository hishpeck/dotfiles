return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<Leader>dt", function()
			dap.toggle_breakpoint()
		end, { desc = "Toggle breakpoint" })
		vim.keymap.set("n", "<Leader>dc", function()
			dap.continue()
		end, { desc = "Continue debugging" })
		vim.keymap.set("n", "<Leader>dx", function()
			dapui.close()
		end, { desc = "Close debugger" })

		dap.adapters.codelldb = {
			type = "server",
			port = 13131,
			executable = {
				command = "codelldb",
				args = { "--port", 13131 },
			},
		}

		dap.adapters.gdb = {
			type = "server",
			host = "127.0.0.1",
			port = 1337,
		}

		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = "cpptools",
		}

		dap.adapters.php = {
			type = "executable",
			command = "node",
			args = { "phpDebug.js" },
		}

		dap.configurations.rust = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
			{
				name = "Attach to gdbserver :1337",
				type = "cppdbg",
				request = "launch",
				MIMode = "gdb",
				miDebuggerServerAddress = "localhost:1337",
				miDebuggerPath = "/usr/bin/gdb-multiarch",
				cwd = "${workspaceFolder}",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
			},
		}

		dap.configurations.php = {
			{
				type = "php",
				request = "launch",
				name = "Listen for Xdebug",
				port = 9003,
			},
		}

		require("dap.ext.vscode").load_launchjs(nil, {
			gdb = { "rs" },
		})
	end,
}
