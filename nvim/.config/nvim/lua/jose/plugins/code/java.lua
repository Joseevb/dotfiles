-- lua/jose/plugins/code/java.lua
return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	-- Ensure DAP is loaded before trying to configure it
	dependencies = {
		"mfussenegger/nvim-dap",
		"williamboman/mason.nvim", -- Needed for mason_registry
		"neovim/nvim-lspconfig", -- Needed for basic LSP capabilities
		"hrsh7th/cmp-nvim-lsp", -- Needed for cmp capabilities below
		-- Optional but recommended dependencies:
		"rcarriga/nvim-dap-ui", -- UI for DAP
		"nvim-neotest/neotest", -- If using neotest integration
		"rcasia/neotest-java", -- If using neotest integration
	},
	config = function()
		-- Prerequisites check: Ensure required Mason packages are installed
		local mason_registry = require("mason-registry")
		local required_pkgs = { "jdtls", "java-debug-adapter", "java-test", "vscode-java-decompiler" }
		local missing_pkgs = {}
		local pkg_paths = {}

		for _, pkg_name in ipairs(required_pkgs) do
			local pkg = mason_registry.get_package(pkg_name)
			if not pkg or not pkg:is_installed() then
				table.insert(missing_pkgs, pkg_name)
			else
				pkg_paths[pkg_name] = pkg:get_install_path()
			end
		end

		if #missing_pkgs > 0 then
			vim.notify(
				"Mason packages required for nvim-jdtls are missing: " .. table.concat(missing_pkgs, ", "),
				vim.log.levels.ERROR
			)
			return -- Stop configuration if essential packages are missing
		end

		-- --- Setup Variables ---
		local jdtls = require("jdtls")
		local jdtls_path = pkg_paths["jdtls"]
		local java_debug_path = pkg_paths["java-debug-adapter"]
		local java_test_path = pkg_paths["java-test"]
		local java_decompiler_path = pkg_paths["vscode-java-decompiler"]

		-- Determine Java executable (more robustly)
		local java_cmd = vim.fn.expand("~/.sdkman/candidates/java/current/bin/java") -- Your specific path
		-- Alternative: Check common locations or $JAVA_HOME
		if vim.fn.executable(java_cmd) == 0 then
			java_cmd = os.getenv("JAVA_HOME") .. "/bin/java" -- Check JAVA_HOME
		end
		if vim.fn.executable(java_cmd) == 0 then
			java_cmd = "java" -- Fallback to hoping 'java' is in PATH
			vim.notify(
				"JDTLS: Could not find Java via SDKMAN path, defaulting to 'java'. Ensure Java is in your PATH.",
				vim.log.levels.WARN
			)
		end

		-- Decompiler JARs
		local decompiler_jars = vim.fn.glob(java_decompiler_path .. "/server/*.jar", true, true)

		-- OS specific config path (config_linux, config_mac, config_win)
		local os_name = vim.loop.os_uname().sysname
		local config_dir_name
		if os_name == "Linux" then
			config_dir_name = "config_linux"
		elseif os_name == "Darwin" then
			config_dir_name = "config_mac"
		elseif os_name == "Windows" then
			config_dir_name = "config_win"
		else
			vim.notify("JDTLS: Unsupported OS for config path detection: " .. os_name, vim.log.levels.ERROR)
			return
		end
		local config_os_path = vim.fs.joinpath(jdtls_path, config_dir_name)

		-- Launcher JAR and Lombok
		local equinox_launcher_glob = vim.fs.joinpath(jdtls_path, "plugins", "org.eclipse.equinox.launcher_*.jar")
		local equinox_launcher_path = vim.fn.glob(equinox_launcher_glob, true, true)[1]
		local lombok_path = vim.fs.joinpath(jdtls_path, "lombok.jar")

		-- Verify critical paths exist
		if not equinox_launcher_path or vim.fn.filereadable(equinox_launcher_path) == 0 then
			vim.notify("JDTLS Error: Could not find or read equinox launcher JAR.", vim.log.levels.ERROR)
			return
		end
		if not config_os_path or vim.fn.isdirectory(config_os_path) == 0 then
			vim.notify(
				"JDTLS Error: Could not find OS-specific config directory: " .. config_os_path,
				vim.log.levels.ERROR
			)
			return
		end
		if vim.fn.filereadable(lombok_path) == 0 then
			vim.notify("JDTLS Warning: lombok.jar not found at " .. lombok_path, vim.log.levels.WARN)
			-- Lombok is often bundled, but let's not make it a fatal error if missing temporarily
		end

		-- --- JDTLS Startup Function ---
		local function setup_jdtls()
			-- Find project root relative to the current buffer's directory
			local current_buf_path = vim.api.nvim_buf_get_name(0)
			local current_dir = vim.fn.fnamemodify(current_buf_path, ":h")
			local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
			local root_dir = require("jdtls.setup").find_root(root_markers, current_dir)

			if root_dir == "" or root_dir == vim.fn.expand("~") then
				-- Avoid starting if not in a Java project relative to current file
				return
			end

			local project_name = vim.fn.fnamemodify(root_dir, ":t") -- Get project directory name
			local workspace_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "jdtls-workspace", project_name)

			-- Construct bundles list
			local bundles = {}
			local debug_adapter_jars =
				vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)
			local java_test_jars =
				vim.fn.glob(java_test_path .. "/extension/server/com.microsoft.java.test.plugin-*.jar", true, true)

			vim.list_extend(bundles, debug_adapter_jars)
			vim.list_extend(bundles, java_test_jars)
			vim.list_extend(bundles, decompiler_jars)

			local jdtls_extended_caps = require("jdtls").extendedClientCapabilities
			local extendedClientCapabilities = vim.deepcopy(jdtls_extended_caps) -- Use deepcopy
			extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

			-- Main JDTLS Language Server configuration table
			local config = {
				cmd = {
					java_cmd,
					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=WARN", -- Reduced default log level (INFO or WARN)
					"-Xmx2g", -- Adjust as needed
					"--add-modules=ALL-SYSTEM",
					"--add-opens",
					"java.base/java.util=ALL-UNNAMED",
					"--add-opens",
					"java.base/java.lang=ALL-UNNAMED",
					"-javaagent:" .. lombok_path,
					"-jar",
					equinox_launcher_path,
					"-configuration",
					config_os_path,
					"-data",
					workspace_dir,
				},
				root_dir = root_dir,
				-- Attach standard Neovim LSP client capabilities merged with CMP capabilities
				capabilities = require("cmp_nvim_lsp").default_capabilities(
					vim.lsp.protocol.make_client_capabilities()
				),
				init_options = {
					bundles = bundles,
					extendedClientCapabilities = extendedClientCapabilities, -- Use the merged table
				},
				settings = {
					java = {
						-- Setting related to conform.nvim (if used) - Tell JDTLS formatter is disabled
						format = { enabled = false },
						-- Other settings...
						eclipse = { downloadSources = true },
						maven = { downloadSources = true },
						implementationsCodeLens = { enabled = true },
						referencesCodeLens = { enabled = true },
						inlayHints = { parameterNames = { enabled = true } },
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" },
						references = { includeDecompiledSources = true },
						-- Consider commenting out these intensive library scans if JDTLS picks up
						-- dependencies automatically from Maven/Gradle, which it usually does.
						-- project = {
						--   referencedLibraries = {
						--     "lib/**/*.jar",
						--     vim.fn.expand("~/.m2/repository/**/*.jar"),
						--     -- Consider a more specific glob for gradle if needed
						--     -- vim.fn.expand("~/.gradle/caches/modules-2/files-2.1/**/some-pattern-*.jar"),
						--   },
						-- },
					},
				},
				on_attach = function(_, bufnr)
					vim.notify(
						"JDTLS attached to buffer " .. bufnr .. " for project " .. project_name,
						vim.log.levels.INFO
					)

					require("jdtls").setup_dap({ hotcodereplace = "auto", config_overrides = {} })
					vim.schedule(function()
						require("jdtls.dap").setup_dap_main_class_configs()
					end)

					-- Standard LSP mappings
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(
							mode,
							lhs,
							rhs,
							{ silent = true, noremap = true, buffer = bufnr, desc = "LSP: " .. desc }
						)
					end

					-- Load telescope builtins only if Telescope is available (optional robustness)
					local telescope_ok, telescope = pcall(require, "telescope.builtin")

					-- Standard LSP mappings
					map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
					map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
					-- Use Telescope for implementations if available
					if telescope_ok then
						map("n", "gi", telescope.lsp_implementations, "Go to Implementation (Telescope)")
					else
						map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
					end
					-- Use Telescope for references if available
					if telescope_ok then
						map("n", "gr", telescope.lsp_references, "Go to References (Telescope)")
					else
						map("n", "gr", vim.lsp.buf.references, "Go to References")
					end
					-- map("n", "K", vim.lsp.buf.hover, "Hover")
					map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
					map("n", "<leader>D", vim.lsp.buf.type_definition, "Type Definition")
					map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
					map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

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

					-- DAP related mappings (require nvim-dap)
					map("n", "<leader>dt", function()
						require("jdtls").test_class()
					end, "Run/Debug Test Class")
					map("n", "<leader>dn", function()
						require("jdtls").test_nearest_method()
					end, "Run/Debug Test Method")
					map("n", "<leader>dR", function()
						require("dap").run_to_cursor()
					end, "DAP: Run To Cursor")
					map("n", "<leader>dS", function()
						require("dap").step_into()
					end, "DAP: Step Into")
					map("n", "<leader>do", function()
						require("dap").step_out()
					end, "DAP: Step Out")
					map("n", "<leader>db", function()
						require("dap").toggle_breakpoint()
					end, "DAP: Toggle Breakpoint")
					map("n", "<leader>dc", function()
						require("dap").continue()
					end, "DAP: Continue") -- Add continue
					map("n", "<leader>dr", function()
						require("dap").repl.open()
					end, "DAP: Open REPL") -- Add REPL
				end,
				-- handlers = {}, -- Custom handlers can go here
			}

			-- REMOVED: the noisy bundle print statement

			-- Start the JDTLS client
			jdtls.start_or_attach(config)
			vim.notify("JDTLS start request sent.", vim.log.levels.INFO)
		end

		-- Use an autocmd to trigger the setup when entering a Java buffer.
		vim.api.nvim_create_augroup("UserJdtlsStartGroup", { clear = true }) -- Use unique group name
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = setup_jdtls,
			group = "UserJdtlsStartGroup",
			desc = "Start JDTLS for Java files",
		})

		-- Command to manually restart JDTLS using the CURRENT API
		vim.api.nvim_create_user_command("JdtlsRestart", function()
			vim.notify("Attempting to restart JDTLS...", vim.log.levels.INFO)
			local jdtls_clients = vim.lsp.get_clients({ name = "jdtls", bufnr = 0 }) -- Check clients attached to any buffer

			if #jdtls_clients == 0 then
				vim.notify("No running JDTLS clients found. Attempting to start...", vim.log.levels.INFO)
				setup_jdtls()
			else
				vim.notify("Found " .. #jdtls_clients .. " JDTLS client(s). Stopping...", vim.log.levels.INFO)
				local client_ids = {}
				for _, client in ipairs(jdtls_clients) do
					table.insert(client_ids, client.id)
				end
				if #client_ids > 0 then
					vim.lsp.stop_client(client_ids, true) -- force=true for sync stop
					vim.notify("JDTLS client(s) stop request sent.", vim.log.levels.INFO)
				end
				-- Defer the restart slightly
				vim.defer_fn(function()
					vim.notify("Restarting JDTLS...", vim.log.levels.INFO)
					setup_jdtls()
				end, 1000)
			end
		end, { desc = "Restart JDTLS client(s)" })

		print("nvim-jdtls user configuration loaded.") -- Startup confirmation
	end,
}
