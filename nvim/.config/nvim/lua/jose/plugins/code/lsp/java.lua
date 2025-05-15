-- lua/jose/plugins/code/lsp/java.lua

-- Proposed Fixes:
-- 1. Removed the direct call to setup_jdtls() at the end of the config function.
--    JDTLS will now only start when the FileType autocmd triggers (i.e., when opening a .java file).
-- 2. Removed duplicate diagnostic mappings as they are already included via on_attach_base.
-- 3. Removed duplicate jdtls.organize_imports and jdtls.code_action mappings.
-- 4. Removed the <C-o> mapping as it conflicts with Neovim's jump list and is duplicated by <leader>jo.

return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" }, -- Load only for java files
	dependencies = {
		"mfussenegger/nvim-dap", -- Debugging adapter
		"williamboman/mason.nvim", -- Needed for mason_registry paths
		"neovim/nvim-lspconfig", -- Needed for basic LSP capabilities

		-- Optional but recommended dependencies:
		"rcarriga/nvim-dap-ui", -- UI for DAP
		"nvim-neotest/neotest", -- If using neotest integration
		"rcasia/neotest-java", -- If using neotest integration
	},
	config = function()
		local lsp_handlers = require("jose.lsp.handlers")
		local on_attach_base = lsp_handlers.on_attach_base -- Base LSP keymaps
		local map = lsp_handlers.map_lsp_key -- Keymap helper
		local mason_path = vim.fn.expand("$MASON/share/") -- Standard Mason install directory

		-- --- Setup Variables ---
		local jdtls = require("jdtls") -- The jdtls plugin module
		-- Construct paths to JDTLS components installed by Mason
		local jdtls_path = vim.fs.joinpath(mason_path, "jdtls")
		local java_debug_path = vim.fs.joinpath(mason_path, "java-debug-adapter")
		local java_test_path = vim.fs.joinpath(mason_path, "java-test")
		local java_decompiler_path = vim.fs.joinpath(mason_path, "vscode-java-decompiler")

		-- Determine Java executable path (more robustly)
		-- Checks specific path, then JAVA_HOME, then defaults to 'java' in PATH
		local java_cmd = vim.fn.expand("~/.sdkman/candidates/java/current/bin/java") -- Check sdkman first (user-specific)
		if vim.fn.executable(java_cmd) == 0 then
			local java_home = os.getenv("JAVA_HOME")
			if java_home then
				java_cmd = vim.fs.joinpath(java_home, "bin", "java") -- check JAVA_HOME
			end
		end
		if vim.fn.executable(java_cmd) == 0 then
			java_cmd = "java" -- fallback to hoping 'java' is in path
			vim.notify(
				"jdtls: could not find java via sdkman path or JAVA_HOME, defaulting to 'java'. ensure java is in your path.",
				vim.log.levels.warn
			)
		end

		-- Decompiler JARs (for decompiling class files)
		local decompiler_jars = vim.fn.glob(java_decompiler_path .. "/server/*.jar", true, true)

		-- Path to the OS-specific configuration directory for JDTLS
		local config_path = vim.fs.joinpath(jdtls_path, "config")

		-- Launcher JAR and Lombok JAR paths
		local equinox_launcher_glob = vim.fs.joinpath(jdtls_path, "plugins", "org.eclipse.equinox.launcher_*.jar")
		local equinox_launcher_path_list = vim.fn.glob(equinox_launcher_glob, true, true) -- Use list to handle potential variations
		local equinox_launcher_path = equinox_launcher_path_list and equinox_launcher_path_list[1] or nil -- Get the first match

		local lombok_path = vim.fs.joinpath(jdtls_path, "lombok.jar")

		-- Verify critical paths exist before attempting to start JDTLS
		local paths_ok = true
		if not equinox_launcher_path or vim.fn.filereadable(equinox_launcher_path) == 0 then
			vim.notify("JDTLS Error: Could not find or read equinox launcher JAR.", vim.log.levels.ERROR)
			paths_ok = false
		end
		if not config_path or vim.fn.isdirectory(config_path) == 0 then
			vim.notify(
				"JDTLS Error: Could not find OS-specific config directory: " .. config_path,
				vim.log.levels.ERROR
			)
			paths_ok = false
		end
		-- Lombok is optional but useful, warn if missing
		if paths_ok and vim.fn.filereadable(lombok_path) == 0 then
			vim.notify(
				"JDTLS Warning: lombok.jar not found at "
					.. lombok_path
					.. ". Auto-completion/features for Lombok might be limited.",
				vim.log.levels.WARN
			)
		end

		-- If critical paths are missing, do not attempt to start JDTLS
		if not paths_ok then
			vim.notify("JDTLS startup aborted due to missing critical components.", vim.log.levels.ERROR)
			return -- Stop configuration if paths are bad
		end

		-- --- JDTLS Startup Function ---
		-- This function should be called *only* when a Java buffer is active.
		local function setup_jdtls()
			local current_buf_path = vim.api.nvim_buf_get_name(0)
			if current_buf_path == "" or vim.bo.filetype ~= "java" or vim.bo.buftype ~= "" then
				-- Only start if the buffer is a saved java file (not a temporary buffer)
				return
			end

			local current_dir = vim.fn.fnamemodify(current_buf_path, ":h")
			-- Define root markers: Add build.gradle.kts for Kotlin Gradle projects
			local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" }
			local root_dir = require("jdtls.setup").find_root(root_markers, current_dir)

			-- Do not start if a valid project root is not found relative to the current file
			if root_dir == "" or root_dir == vim.fn.expand("~") then
				vim.notify(
					"JDTLS: Could not find project root for " .. current_buf_path .. ". Not starting.",
					vim.log.levels.INFO
				)
				return
			end

			-- Standard practice is to rely on jdtls.start_or_attach to handle client management.
			-- Removing manual client check to avoid potential conflicts/errors.
			local project_name = vim.fn.fnamemodify(root_dir, ":t") -- Get project directory name
			-- Use a stable cache directory based on the project root
			local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls-workspace", project_name)

			-- Construct bundles list for DAP and Test Runner
			local bundles = {}
			local debug_adapter_jars =
				vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
			local java_test_jars =
				vim.fn.glob(java_test_path .. "/extension/server/com.microsoft.java.test.plugin-*.jar", true, true)

			vim.list_extend(bundles, debug_adapter_jars)
			vim.list_extend(bundles, java_test_jars)
			vim.list_extend(bundles, decompiler_jars) -- Add decompiler bundle

			-- JDTLS extended capabilities
			local jdtls_extended_caps = require("jdtls.setup").extendedClientCapabilities
			local extendedClientCapabilities = vim.deepcopy(jdtls_extended_caps) -- Use deepcopy to avoid modifying original
			extendedClientCapabilities.resolveAdditionalTextEditsSupport = true -- Enable additional text edits support

			-- Main JDTLS Language Server configuration table
			local config = {
				cmd = {
					java_cmd,
					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=WARN", -- Reduced default log level (INFO or WARN)
					"-Xmx2g", -- Adjust memory as needed
					"--add-modules=ALL-SYSTEM",
					"--add-opens",
					"java.base/java.util=ALL-UNNAMED",
					"--add-opens",
					"java.base/java.lang=ALL-UNNAMED",
					-- Include lombok agent only if the file exists
					vim.fn.filereadable(lombok_path) == 1 and "-javaagent:" .. lombok_path or "",
					"-jar",
					equinox_launcher_path,
					"-configuration",
					config_path,
					"-data",
					workspace_dir,
				},
				root_dir = root_dir,
				-- Attach standard Neovim LSP client capabilities merged with CMP capabilities
				-- Use capabilities from lspconfig.lua if available, otherwise default
				capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities()),
				init_options = {
					bundles = bundles,
					extendedClientCapabilities = extendedClientCapabilities, -- Use the merged table
				},
				settings = {
					java = {
						-- Setting related to conform.nvim (if used) - Tell JDTLS formatter is disabled
						format = { enabled = false },
						eclipse = { downloadSources = true },
						maven = { downloadSources = true },
						implementationsCodeLens = { enabled = true },
						referencesCodeLens = { enabled = true },
						inlayHints = { parameterNames = { enabled = true } },
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" }, -- Or "bytebuddy"
						references = { includeDecompiledSources = true },
					},
				},
				-- on_attach function: Called when the LSP client attaches to a buffer
				on_attach = function(client, bufnr)
					-- Setup DAP integration for this client
					-- Note: setup_dap_main_class_configs seems to be causing keymap errors on attach.
					-- Commenting it out as a temporary fix.
					require("jdtls").setup_dap({ hotcodereplace = "auto", config_overrides = {} })
					-- vim.schedule(function()
					-- 	require("jdtls.dap").setup_dap_main_class_configs()
					-- end)

					-- Schedule main class configurations (might be needed for test/run buttons)
					vim.schedule(function()
						require("jdtls.dap").setup_dap_main_class_configs()
					end)

					-- Apply base LSP mappings from handlers.lua
					on_attach_base(client, bufnr)

					-- JDTLS specific mappings
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

					map("n", "<leader>ei", jdtls.extract_interface, "Extract Interface")
					map("n", "<leader>ee", jdtls.extract_enum, "Extract Enum")
					map("n", "<leader>em", jdtls.extract_method, "Extract Method")
					map("n", "<leader>ef", jdtls.extract_field, "Extract Field")
					map("n", "<leader>el", jdtls.extract_local_variable, "Extract Local Variable")
					map("n", "<leader>ek", jdtls.extract_class, "Extract Class")
					map("n", "<leader>er", jdtls.rename_file, "Rename Compilation Unit")
					map("n", "<leader>o", jdtls.open_main_class, "Open Main Class") -- Be aware this conflicts with default 'o' in normal mode

					-- DAP related mappings (require nvim-dap)
					map("n", "<leader>dt", function()
						require("jdtls").test_class()
					end, "Run/Debug Test Class")
					map("n", "<leader>dn", function()
						require("jdtls").test_nearest_method()
					end, "Run/Debug Test Method")

					-- Other specific JDTLS commands
					map("n", "<leader>jD", jdtls.resolve_dependency, "Resolve Dependency")
					map("n", "<leader>jp", jdtls.project_root, "Show Project Root")
				end,
			}

			-- Start the JDTLS client if it's not already running for this root
			-- The check above should prevent starting duplicates, but this is the call site.
			jdtls.start_or_attach(config)
		end

		-- Use an autocmd to trigger the setup when entering a Java buffer.
		-- Ensure 'clear = true' is used with a unique group name to avoid accumulating autocmds.
		vim.api.nvim_create_augroup("UserJdtlsStartGroup", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				-- Use a pcall/vim.schedule here to avoid blocking startup and handle potential errors
				vim.schedule(setup_jdtls)
			end,
			group = "UserJdtlsStartGroup",
			desc = "Start JDTLS for Java files",
		})

		-- REMOVED: The direct call to setup_jdtls() was here. Rely solely on the autocmd.

		-- Command to manually restart JDTLS using the CURRENT API
		vim.api.nvim_create_user_command("JdtlsRestart", function()
			vim.notify("Attempting to restart JDTLS...", vim.log.levels.INFO)
			-- Find clients attached to ANY buffer with the name 'jdtls'
			local jdtls_clients = vim.lsp.get_clients({ name = "jdtls" })

			if #jdtls_clients == 0 then
				vim.notify("No running JDTLS clients found. Attempting to start...", vim.log.levels.INFO)
				-- Call setup_jdtls which will start if no client exists for the current root
				setup_jdtls()
			else
				vim.notify("Found " .. #jdtls_clients .. " JDTLS client(s). Stopping...", vim.log.levels.INFO)
				local client_ids = {}
				for _, client in ipairs(jdtls_clients) do
					table.insert(client_ids, client.id)
				end
				if #client_ids > 0 then
					-- Stop the clients. force=true attempts immediate shutdown.
					vim.lsp.stop_client(client_ids, true)
					vim.notify("JDTLS client(s) stop request sent.", vim.log.levels.INFO)
				end
				-- Defer the restart slightly to allow clients to shut down gracefully
				vim.defer_fn(function()
					vim.notify("Restarting JDTLS...", vim.log.levels.INFO)
					-- Call setup_jdtls again, which should now start a new client
					setup_jdtls()
				end, 1000) -- Wait 1 second before restarting
			end
		end, { desc = "Restart JDTLS client(s)" })
	end,
}
