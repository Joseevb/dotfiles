return {
	{
		src = "https://codeberg.org/mfussenegger/nvim-dap.git",
		setup_name = "dap",
	},
	{
		src = "https://github.com/rcarriga/nvim-dap-ui",
		setup_name = "dapui",
		opts = {
			icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				repl = "R",
				edit = "e",
			},
			expand_lines = true,
			layout = "current",
			floating = {
				max_height = nil,
				max_width = nil,
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			windows = {
				indent = 1,
			},
			render = {
				max_type_length = nil,
			},
			listeners = {
				before = {
					["dapui_config"] = function()
						local dap, dapui = require("dap"), require("dapui")
						dap.listeners.after.event_initialized["dapui_config"] = function()
							dapui.open({})
						end
						dap.listeners.before.event_terminated["dapui_config"] = function()
							dapui.close({})
						end
						dap.listeners.before.event_exited["dapui_config"] = function()
							dapui.close({})
						end
					end,
				},
			},
		},
	},
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
}
