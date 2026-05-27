return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "<Leader>dt", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
		{ "<Leader>dc", function() require("dap").continue() end, desc = "Continue debugging" },
		{ "<Leader>dx", function() require("dapui").close() end, desc = "Close debugger" },
	},
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
			args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
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
				name = "Listen for Xdebug (Port 9003)",
				port = 9003,
			},
			{
				type = "php",
				request = "launch",
				name = "Car & Classic (Port 9998)",
				port = 9998,
				pathMappings = {
					["/app/laravel"] = "${workspaceFolder}/laravel",
					["/app"] = "${workspaceFolder}",
				},
				log = true,
			},
		}
	end,
}
