-- This configuration uses nvim-jdtls.
return {
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		config = function()
			local on_attach = function(client, bufnr)
				local function buf_set_keymap(...)
					vim.api.nvim_buf_set_keymap(bufnr, ...)
				end
				local function buf_set_option(...)
					vim.api.nvim_buf_set_option(bufnr, ...)
				end

				buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
				local opts = { noremap = true, silent = true }

				buf_set_keymap("n", "gD", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				buf_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
				buf_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
				buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
				buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
				buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
				buf_set_keymap("n", "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", opts)
				buf_set_keymap("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				client.server_capabilities.document_formatting = true
			end
			local mason = require("mason-registry")
			local jdtls_path = mason.get_package("jdtls"):get_install_path()
			local java_debug_path = mason.get_package("java-debug-adapter"):get_install_path()
			local java_test_path = mason.get_package("java-test"):get_install_path()

			local equinox_launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

			local system = "linux"
			local config_path = vim.fn.glob(jdtls_path .. "/config_" .. system)

			local lombok_path = jdtls_path .. "/lombok.jar"

			local jdtls = require("jdtls")

			local config = {
				cmd = {
					vim.fn.expand("~/.sdkman/candidates/java/23-open/bin/java"), -- or '/path/to/java17_or_newer/bin/java'

					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=ALL",
					"-Xmx1g",
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
					vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
				},

				root_dir = vim.fs.root(0, { "mvnw", "gradlew" }),

				on_attach = on_attach,

				capabilities = require("cmp_nvim_lsp").default_capabilities(),

				-- Here you can configure eclipse.jdt.ls specific settings
				-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
				-- for a list of options
				settings = {
					java = {
						server = { launchMode = "Hybrid" },
						eclipse = {
							downloadSources = true,
						},
						maven = {
							downloadSources = true,
						},
						configuration = {
							runtimes = {
								{
									name = "JavaSE-17",
									path = vim.fn.expand("~/.sdkman/candidates/java/17*"),
								},
								{
									name = "JavaSE-23",
									path = vim.fn.expand("~/.sdkman/candidates/java/23-open"),
									default = true,
								},
							},
							annotations = {
								enabled = true,
							},
						},
						references = {
							includeDecompiledSources = true,
						},
						implementationsCodeLens = {
							enabled = false,
						},
						referenceCodeLens = {
							enabled = false,
						},
						inlayHints = {
							parameterNames = {
								enabled = "none",
							},
						},
						signatureHelp = {
							enabled = true,
							description = {
								enabled = true,
							},
						},
						sources = {
							organizeImports = {
								starThreshold = 9999,
								staticStarThreshold = 9999,
							},
						},
					},
					redhat = { telemetry = { enabled = false } },
				},
			}

			local bundles = {
				vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"),
			}

			vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/server/*.jar"), "\n"))

			config["init_options"] = {
				bundles = bundles,
			}

			jdtls.start_or_attach(config)
		end,
	},
}
