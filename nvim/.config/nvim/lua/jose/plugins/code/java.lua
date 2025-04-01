-- lua/plugins/java.lua (or wherever you store this configuration)
return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		local jdtls = require("jdtls")
		local mason_registry = require("mason-registry") -- Renamed variable for clarity, ensure mason-registry is available

		-- Ensure the required Mason packages are installed
		-- This could be done via ensure_installed in nvim-lspconfig or mason.nvim setup,
		-- but checking paths here provides fallback and verification.
		local jdtls_pkg = mason_registry.get_package("jdtls")
		if not jdtls_pkg then
			vim.notify("Mason: jdtls package not found", vim.log.levels.WARN)
			return
		end
		local java_debug_pkg = mason_registry.get_package("java-debug-adapter")
		if not java_debug_pkg then
			vim.notify("Mason: java-debug-adapter package not found", vim.log.levels.WARN)
			return
		end
		local java_test_pkg = mason_registry.get_package("java-test")
		if not java_test_pkg then
			vim.notify("Mason: java-test package not found", vim.log.levels.WARN)
			return
		end
		local java_decompiler_pkg = mason_registry.get_package("vscode-java-decompiler")
		if not java_decompiler_pkg then
			vim.notify("Mason: vscode-java-decompiler package not found", vim.log.levels.WARN)
			return
		end

		-- Paths for installed LSP packages
		local jdtls_path = jdtls_pkg:get_install_path()
		local java_debug_path = java_debug_pkg:get_install_path()
		local java_test_path = java_test_pkg:get_install_path()
		local java_decompiler_path = java_decompiler_pkg:get_install_path()

		-- Decompiler JARs
		-- Use 'true' for absolute paths and 'true' to return a list
		local decompiler_jars = vim.fn.glob(java_decompiler_path .. "/server/*.jar", true, true)

		-- Find the Eclipse JDTLS launcher and config paths
		-- Using find instead of glob to get the first match directly might be slightly cleaner
		local equinox_launcher_path =
			vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", true, true)[1]
		local config_path = vim.fn.glob(jdtls_path .. "/config_linux", true, true)[1] -- Adapt "config_linux" if on mac/windows
		local lombok_path = jdtls_path .. "/lombok.jar"

		-- Verify critical paths
		if not equinox_launcher_path then
			vim.notify("JDTLS Error: Could not find equinox launcher JAR in " .. jdtls_path, vim.log.levels.ERROR)
			return
		end
		if not config_path then
			vim.notify("JDTLS Error: Could not find config_linux directory in " .. jdtls_path, vim.log.levels.ERROR)
			return
		end

		-- --- Configuration Setup Function ---
		local function setup_jdtls()
			-- Find project root
			local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
			local root_dir = require("jdtls.setup").find_root(root_markers)
			if root_dir == "" or root_dir == vim.fn.expand("~") then
				-- Avoid starting JDTLS if not in a recognized Java project directory
				-- print("JDTLS: No project root found or root is home directory. Not starting.")
				return
			end

			local home = vim.fn.expand("$HOME")
			-- Create a unique workspace directory per project
			local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t") -- Get the parent directory name
			local workspace_dir = home .. "/.cache/jdtls-workspace/" .. project_name

			vim.notify(
				"Starting JDTLS for project: " .. project_name .. " in workspace: " .. workspace_dir,
				vim.log.levels.INFO
			)

			-- Construct the bundles list *correctly*
			local bundles = {}
			local debug_adapter_jars =
				vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
			local java_test_jars =
				vim.fn.glob(java_test_path .. "/extension/server/com.microsoft.java.test.plugin-*.jar", true, true)

			vim.list_extend(bundles, debug_adapter_jars)
			vim.list_extend(bundles, java_test_jars)
			vim.list_extend(bundles, decompiler_jars) -- Add decompiler JARs

			-- Basic JDTLS configuration table
			local config = {
				-- autostart = true, -- NOTE: We are manually starting with an autocmd, so autostart isn't needed here
				cmd = {
					vim.fn.expand("~/.sdkman/candidates/java/current/bin/java"), -- Ensure this path is correct for your system
					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=ALL", -- Consider reducing log level (e.g., INFO or WARN) for less verbosity
					"-Xmx2g", -- Adjust memory limit as needed
					"--add-modules=ALL-SYSTEM",
					"--add-opens",
					"java.base/java.util=ALL-UNNAMED",
					"--add-opens",
					"java.base/java.lang=ALL-UNNAMED",
					"-javaagent:" .. lombok_path, -- Add lombok agent
					"-jar",
					equinox_launcher_path,
					"-configuration",
					config_path,
					"-data",
					workspace_dir,
				},
				root_dir = root_dir,
				capabilities = require("cmp_nvim_lsp").default_capabilities(), -- Ensure cmp_nvim_lsp is required elsewhere
				init_options = {
					bundles = bundles, -- Assign the correctly constructed list
					extendedClientCapabilities = vim.tbl_deep_extend(
						"force",
						{},
						require("jdtls").extendedClientCapabilities,
						{
							resolveAdditionalTextEditsSupport = true, -- Often needed for complex refactoring/code actions
						}
					),
				},
				settings = {
					java = {
						format = {
							-- Optional: Specify formatter settings if needed
							-- settings = {
							-- 	url = "/path/to/your/eclipse-formatter.xml",
							-- 	profile = "YourProfileName",
							-- },
						},
						eclipse = { downloadSources = true },
						maven = { downloadSources = true },
						implementationsCodeLens = { enabled = true },
						referencesCodeLens = { enabled = true },
						inlayHints = { parameterNames = { enabled = true } },
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" }, -- Use the bundled decompiler
						-- If using external decompiler jar explicitly, you might not need this or 'references.includeDecompiledSources'
						references = { includeDecompiledSources = true },
						project = {
							referencedLibraries = {
								-- These globs can be resource-intensive. Consider limiting them or relying on JDTLS finding build tool dependencies.
								"lib/**/*.jar",
								vim.fn.expand("~/.m2/repository/**/*.jar"),
								-- vim.fn.expand("~/.gradle/caches/modules-2/files-2.1/**/*.jar"), -- Gradle path is more complex
							},
							-- Optional: Exclude specific folders from JDTLS scanning
							-- resourceFilters = {"node_modules", ".git", ".settings", "target", "bin"},
						},
						-- Optional: Configure Java runtime environment if needed, otherwise uses the one starting JDTLS
						-- javaRuntime = { ... },
						-- import = { ... }, -- Optional: import order, etc.
					},
				},
				on_attach = function(client, bufnr)
					vim.notify("JDTLS attached to buffer " .. bufnr, vim.log.levels.INFO)
					-- Standard LSP mappings
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(
							mode,
							lhs,
							rhs,
							{ silent = true, noremap = true, buffer = bufnr, desc = "LSP: " .. desc }
						)
					end
					map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
					map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
					map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation") -- Prefer built-in LSP unless Telescope is desired
					map("n", "gr", vim.lsp.buf.references, "Go to References") -- Prefer built-in LSP unless Telescope is desired
					map("n", "K", vim.lsp.buf.hover, "Hover")
					map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
					map("n", "<leader>D", vim.lsp.buf.type_definition, "Type Definition")
					map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, "Format Code")

					-- JDTLS specific mappings and commands
					map("n", "<C-o>", jdtls.organize_imports, "Organize Imports")
					map("n", "<leader>ev", function()
						jdtls.extract_variable({ visual = false })
					end, "Extract Variable")
					map("v", "<leader>ev", function()
						jdtls.extract_variable({ visual = true })
					end, "Extract Variable (Visual)")
					map("n", "<leader>ec", function()
						jdtls.extract_constant({ visual = false })
					end, "Extract Constant")
					map("v", "<leader>ec", function()
						jdtls.extract_constant({ visual = true })
					end, "Extract Constant (Visual)")
					-- map("n", "<leader>em", function() jdtls.extract_method({ visual = false }) end, "Extract Method") -- Example if needed
					-- map("v", "<leader>em", function() jdtls.extract_method({ visual = true }) end, "Extract Method (Visual)")

					-- Add Java debugger and test runner mappings/commands here if using nvim-dap & nvim-jdtls extensions
					require("jdtls").setup_dap({ hotcodereplace = "auto" })
					require("jdtls.dap").setup_dap_main_class_configs()
					-- Example mappings using nvim-dap (requires nvim-dap setup)
					map("n", "<leader>dt", function()
						require("jdtls").test_class()
					end, "Debug Test Method")
					map("n", "<leader>dn", function()
						require("jdtls").test_nearest_method()
					end, "Debug Nearest Test Method")
					map("n", "<leader>dR", function()
						require("dap").run_to_cursor()
					end, "Run To Cursor")
					map("n", "<leader>dS", function()
						require("dap").step_into()
					end, "Step Into")
					map("n", "<leader>do", function()
						require("dap").step_out()
					end, "Step Out")
					map("n", "<leader>db", function()
						require("dap").toggle_breakpoint()
					end, "Toggle Breakpoint")
					-- Setup test runner integration (example using Neotest - requires neotest and neotest-java setup)
					-- require('neotest').setup({ adapters = { require('neotest-java') }})
				end,
				-- handlers = { ... } -- Optional: Override default LSP handlers if needed
			}

			-- Debugging: Print the final config table before starting
			-- vim.notify("JDTLS final config: " .. vim.inspect(config), vim.log.levels.DEBUG)

			-- Debugging: Explicitly print the bundles list right before start
			vim.schedule(function()
				print("JDTLS Bundles FINAL Check:", vim.inspect(config.init_options.bundles))
			end)

			-- Start the JDTLS client
			jdtls.start_or_attach(config)
		end

		-- Use an autocmd to trigger the setup when entering a Java buffer.
		-- Clear previous autocmds for this group to prevent duplicates on reload.
		vim.api.nvim_create_augroup("MyJdtlsStartGroup", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = setup_jdtls, -- Call the setup function
			group = "MyJdtlsStartGroup",
			desc = "Start JDTLS for Java files",
		})

		-- Optional: Command to manually restart JDTLS for the current project
		vim.api.nvim_create_user_command("JdtlsRestart", function()
			-- We might need to stop it first if jdtls.stop() exists or by finding the client
			local clients = vim.lsp.get_active_clients({ name = "jdtls" })
			if #clients > 0 then
				vim.notify("Stopping existing JDTLS client(s)...", vim.log.levels.INFO)
				vim.lsp.stop_client(clients, true) -- Force stop sync
			end
			vim.defer_fn(function()
				vim.notify("Restarting JDTLS...", vim.log.levels.INFO)
				setup_jdtls()
			end, 500) -- Delay slightly to ensure old client is stopped
		end, { desc = "Restart JDTLS for the current project" })

		print("nvim-jdtls configuration loaded.") -- Confirmation message
	end,
	dependencies = {
		-- Required for CMP completion capabilities setup
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		-- Required if you use the DAP mappings provided in on_attach
		"mfussenegger/nvim-dap",
		"rcarriga/nvim-dap-ui", -- Optional but recommended for DAP
		-- Recommended: dependency tracking and installation with Mason
		"williamboman/mason.nvim",
		-- Optional: If you want Neotest integration as hinted in comments
		"nvim-neotest/neotest",
		"rcasia/neotest-java",
	},
}
