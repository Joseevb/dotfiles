-- === Define DAP Signs ===
vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🔵", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🚫", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })

-- === Tmux Integration ===
-- Helper function to find project root (simple example)
local function get_project_root()
	-- Uses find_root markers from lspconfig if available, otherwise uses current dir
	local util = require("lspconfig.util")
	local buf_path = vim.api.nvim_buf_get_name(0)
	local root_markers = { ".git", "package.json", "tsconfig.json", "pom.xml", "build.gradle" } -- Add more as needed
	if util and util.find_root then
		return util.find_root({ markers = root_markers, bufpath = buf_path }) or vim.fn.getcwd()
	else
		-- Basic fallback if lspconfig util isn't there or fails
		return vim.fn.finddir(table.unpack(root_markers), vim.fn.fnamemodify(buf_path, ":p:h") .. ";")
			or vim.fn.getcwd()
	end
end

-- lua/jose/plugins/code/dap.lua
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- Installs DAP adapters automatically via Mason
		{
			"williamboman/mason.nvim",
			opts = {
				ensure_installed = {
					-- Add languages you want adapters for.
					-- Ensure java-debug-adapter & java-test are installed for Java (from your java.lua)
					-- For JS/TS, install vscode-js-debug:
					"js-debug-adapter", -- Installs 'vscode-js-debug' which provides js-debug-adapter
				},
			},
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			-- Configure which adapters mason-nvim-dap should setup automatically
			opts = {
				ensure_installed = { -- Ensure these are setup by mason-nvim-dap
					"js-debug-adapter",
				},
				handlers = {}, -- Keep empty unless specific handler customization needed
			},
		},

		-- DAP UI
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "nvim-neotest/nvim-nio" }, -- Needed by dap-ui
            -- stylua: ignore
            keys = { -- Define keys to toggle UI elements conveniently
                { "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP: Toggle DAP UI" },
                { "<leader>de", function() require("dapui").eval() end,    desc = "DAP: Eval",         mode = { "n", "v" } },
            },
			opts = {
				listeners = {
					before = {
						event_terminated = {
							["dapui_config"] = function()
								require("dapui").close({})
							end, -- Auto close DAP UI
						},
						event_exited = {
							["dapui_config"] = function()
								require("dapui").close({})
							end, -- Auto close DAP UI
						},
					},
				},
			},
		},

		-- Virtual text for debugger info
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = { -- Customize appearance if desired
				-- Ccontent can include: {variables}, {scopes}, {repl}
				-- virt_text_pos = 'eol',
				-- highlight_changed_variables = true,
			},
		},

		-- Optional: Debugging for web projects (uses js-debug-adapter)
		-- "vscode-js-debug" needs to be installed via Mason.
		-- Requires separate installation of debug browsers like 'debug-adapter-for-firefox' if needed
		{
			"mxsdev/nvim-dap-vscode-js",
			dependencies = { "williamboman/mason.nvim" },
			opts = {
				-- node_path = "node", -- Path to node executable
				debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
				-- debugger_cmd = { "js-debug-adapter" }, -- Command to use VS Code js debug adapter
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
			},
		},
	},

	opts = {
		adapters = {
			["pwa-node"] = {
				type = "server",
				host = "127.0.0.1",
				port = "${port}", -- Port is dynamically assigned
				executable = {
					-- command = "node", -- Use node in path
					-- Use the js-debug-adapter command installed by Mason
					command = vim.fn.stdpath("data")
						.. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
					args = { "${port}" },
				},
			},
			defaults = {
				fallback = {
					external_terminal = {
						command = "tmux",
						-- Use '-h' for horizontal split, remove for vertical (default)
						args = { "split-pane", "-h", "-c", get_project_root }, -- Execute in project root
					},
				},
			},
		},
	},
	config = function()
		local dap = require("dap")

		-- Setup Virtual Text (explicit call is good practice)
		require("nvim-dap-virtual-text").setup()

		-- === JavaScript / TypeScript Node.js Debugging Configurations ===
		-- Uses 'pwa-node' installed via 'js-debug-adapter' (vscode-js-debug)
		dap.adapters["pwa-node"] = {}

		for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
			dap.configurations[language] = {
				-- Example: Launch current file with Node
				{
					type = "pwa-node", -- Match the adapter name
					request = "launch",
					name = "Launch Current File (Node)",
					program = "${file}", -- Debug the current file
					cwd = "${workspaceFolder}", -- Run in the project root
					runtimeExecutable = "node", -- Use node in path, or specify full path
					console = "integratedTerminal", -- Show output in integrated terminal
				},
				-- Example: Attach to running Node process
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach to Node Process",
					processId = require("dap.utils").pick_process, -- Helper to select running process
					cwd = "${workspaceFolder}",
				},
				-- Add more configs as needed (e.g., running npm scripts)
				-- {
				--     type = "pwa-node",
				--     request = "launch",
				--     name = "Debug Jest Tests",
				--     runtimeExecutable = "node",
				--     runtimeArgs = {
				--         "${workspaceFolder}/node_modules/.bin/jest",
				--         "--runInBand",
				--     },
				--     rootPath = "${workspaceFolder}",
				--     cwd = "${workspaceFolder}",
				--     console = "integratedTerminal",
				--     internalConsoleOptions = "neverOpen",
				-- },
			}
		end
	end,

	-- Define keys after config or ensure they use functions defined in config
	keys = {
		-- Grouping key for discoverability
		{ "<leader>d", group = "+debug", mode = { "n", "v" } },

		-- Your existing keys, slightly modified for consistency/clarity
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "DAP: Breakpoint Condition",
		},
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "DAP: Toggle Breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "DAP: Continue",
		},
		-- Define get_args helper or simplify
		{
			"<leader>da",
			function()
				local args = vim.fn.input("Run with Args: ")
				require("dap").continue({ args = vim.split(args, "%s+") })
			end,
			desc = "DAP: Run with Args",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "DAP: Run to Cursor",
		},
		{
			"<leader>dg",
			function()
				require("dap").goto_()
			end,
			desc = "DAP: Go to Line (No Execute)",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "DAP: Step Into",
		},
		{
			"<leader>dj",
			function()
				require("dap").down()
			end,
			desc = "DAP: Down Stackframe",
		},
		{
			"<leader>dk",
			function()
				require("dap").up()
			end,
			desc = "DAP: Up Stackframe",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "DAP: Run Last Config",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "DAP: Step Out",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_over()
			end,
			desc = "DAP: Step Over",
		},
		{
			"<leader>dp",
			function()
				require("dap").pause()
			end,
			desc = "DAP: Pause",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "DAP: Toggle REPL",
		},
		{
			"<leader>ds",
			function()
				require("dap").session()
			end,
			desc = "DAP: Show Session Info",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "DAP: Terminate Session",
		},
		{
			"<leader>dw",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "DAP: Widgets Hover",
		},
	},
}
