return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		local jdtls = require("jdtls")
		local mason = require("mason-registry")

		-- Paths for installed LSP packages
		local jdtls_path = mason.get_package("jdtls"):get_install_path()
		local java_debug_path = mason.get_package("java-debug-adapter"):get_install_path()
		local java_test_path = mason.get_package("java-test"):get_install_path()
		local java_decompiler_path = mason.get_package("vscode-java-decompiler"):get_install_path()

		-- Decompiler JARs
		local decompiler_jars = vim.fn.glob(java_decompiler_path .. "/server/*.jar", false, true)

		-- Find the Eclipse JDTLS launcher
		local equinox_launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		local config_path = vim.fn.glob(jdtls_path .. "/config_linux")
		local lombok_path = jdtls_path .. "/lombok.jar"

		-- Determine project root & workspace directory
		local home = vim.fn.expand("$HOME")
		local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
		local workspace_dir = home .. "/.cache/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

		-- LSP server configuration
		local config = {
			autostart = true,
			cmd = {
				vim.fn.expand("~/.sdkman/candidates/java/current/bin/java"),
				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
				"-Dosgi.bundles.defaultStartLevel=4",
				"-Declipse.product=org.eclipse.jdt.ls.core.product",
				"-Dlog.protocol=true",
				"-Dlog.level=ALL",
				"-Xmx2g",
				"--add-modules=ALL-SYSTEM",
				"--add-opens",
				"java.base/java.util=ALL-UNNAMED",
				"--add-opens",
				"java.base/java.lang=ALL-UNNAMED",
				"-javaagent:" .. lombok_path,
				"-jar",
				equinox_launcher_path,
				"-configuration",
				config_path,
				"-data",
				workspace_dir,
			},

			root_dir = root_dir,
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
			on_attach = function(_, bufnr)
				local function keymap(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
				end

				keymap("gD", vim.lsp.buf.declaration, "Go to declaration")
				keymap("gd", vim.lsp.buf.definition, "Go to definition")
				keymap("gi", require("telescope.builtin").lsp_implementations, "Go to implementation")
				keymap("gr", require("telescope.builtin").lsp_references, "Go to references")
				keymap("K", vim.lsp.buf.hover, "Hover text")
				keymap("<C-k>", vim.lsp.buf.signature_help, "Show signature")
				keymap("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
				keymap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
				keymap("<leader>D", vim.lsp.buf.type_definition, "Go to type definition")
				keymap("<leader>rn", vim.lsp.buf.rename, "Rename")
				keymap("<leader>ca", vim.lsp.buf.code_action, "Code actions")
				keymap("<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, "Format file")
				keymap("<C-o>", jdtls.organize_imports, "Organize imports")
				keymap("<leader>ev", jdtls.extract_variable, "Extract variable")
				keymap("<leader>ec", jdtls.extract_constant, "Extract constant")
			end,

			settings = {
				java = {
					eclipse = { downloadSources = true },
					maven = { downloadSources = true },
					contentProvider = { preferred = "fernflower" }, -- Force fernflower
					project = {
						referencedLibraries = {
							vim.fn.expand("~/.m2/repository/**/*.jar"),
							vim.fn.expand("~/.gradle/caches/**/*.jar"),
							"lib/**/*.jar",
						},
					},
					signatureHelp = { enabled = true },
					implementationsCodeLens = { enabled = true },
					referenceCodeLens = { enabled = true },
					inlayHints = { parameterNames = { enabled = true } },
					references = { includeDecompiledSources = true }, -- Force JDTLS to use decompiler
				},
			},
		}

		-- Load additional extensions
		local bundles = {
			vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"),
		}
		vim.list_extend(bundles, decompiler_jars) -- Ensure decompiler is loaded

		-- Apply bundles to config
		config.init_options = { bundles = bundles }

		-- Debugging Output
		vim.schedule(function()
			print("JDTLS Bundles Loaded:", vim.inspect(bundles))
		end)

		-- Start or attach JDTLS
		jdtls.start_or_attach(config)
	end,
}
