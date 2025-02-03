return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	config = function()
		-- local on_attach = function(client, bufnr)
		-- 	local function buf_set_keymap(...)
		-- 		vim.api.nvim_buf_set_keymap(bufnr, ...)
		-- 	end
		-- 	local function buf_set_option(...)
		-- 		vim.api.nvim_buf_set_option(bufnr, ...)
		-- 	end
		--
		-- 	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
		-- 	local opts = { noremap = true, silent = true }
		--
		-- 	buf_set_keymap("n", "gD", "<cmd>lua require('jdtls').goto_type_definition()<CR>", opts)
		-- 	buf_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
		-- 	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
		-- 	buf_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
		-- 	buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
		-- 	buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
		-- 	buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
		-- 	buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
		-- 	buf_set_keymap("n", "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", opts)
		-- 	buf_set_keymap("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		-- 	client.server_capabilities.document_formatting = true
		-- end

		local on_attach = function(client, bufnr)
			-- Helper function to wrap keymaps with logging
			local function nnoremap(lhs, rhs, opts, desc)
				opts = opts or { noremap = true, silent = true, buffer = bufnr }
				if desc then
					opts.desc = desc
				end

				vim.keymap.set("n", lhs, function()
					vim.notify("Executing: " .. desc, vim.log.levels.INFO)
					rhs()
				end, opts)
			end

			local bufopts = { noremap = true, silent = true, buffer = bufnr }

			-- Regular Neovim LSP client keymappings
			local bufopts = { noremap = true, silent = true, buffer = bufnr }
			nnoremap("gD", vim.lsp.buf.declaration, bufopts, "Go to declaration")
			nnoremap("gd", vim.lsp.buf.definition, bufopts, "Go to definition")
			nnoremap("gi", vim.lsp.buf.implementation, bufopts, "Go to implementation")
			nnoremap("K", vim.lsp.buf.hover, bufopts, "Hover text")
			nnoremap("<C-k>", vim.lsp.buf.signature_help, bufopts, "Show signature")
			nnoremap("<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
			nnoremap("<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")
			nnoremap("<leader>wl", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, bufopts, "List workspace folders")
			nnoremap("<leader>D", vim.lsp.buf.type_definition, bufopts, "Go to type definition")
			nnoremap("<leader>rn", vim.lsp.buf.rename, bufopts, "Rename")
			nnoremap("<leader>ca", vim.lsp.buf.code_action, bufopts, "Code actions")
			vim.keymap.set(
				"v",
				"<leader>ca",
				"<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
				{ noremap = true, silent = true, buffer = bufnr, desc = "Code actions" }
			)
			nnoremap("<leader>f", function()
				vim.lsp.buf.format({ async = true })
			end, bufopts, "Format file")

			-- Java extensions provided by jdtls
			nnoremap("<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
			nnoremap("<leader>ev", jdtls.extract_variable, bufopts, "Extract variable")
			nnoremap("<leader>ec", jdtls.extract_constant, bufopts, "Extract constant")
			vim.keymap.set(
				"v",
				"<leader>em",
				[[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
				{ noremap = true, silent = true, buffer = bufnr, desc = "Extract method" }
			)
		end

		local mason = require("mason-registry")
		local jdtls_path = mason.get_package("jdtls"):get_install_path()
		local java_debug_path = mason.get_package("java-debug-adapter"):get_install_path()
		local java_test_path = mason.get_package("java-test"):get_install_path()

		local equinox_launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

		local system = "linux"
		local config_path = vim.fn.glob(jdtls_path .. "/config_" .. system)

		local lombok_path = jdtls_path .. "/lombok.jar"

		local home = vim.fn.expand("$HOME")
		local root_dir_path = require("jdtls.setup").find_root({ ".project", ".git", "mvnw", "gradlew" })
		-- in case of root_dir_path being nil this will return the current working directory (otherwise it returns the folder name)
		local root_dir_name = vim.fn.fnamemodify(root_dir_path, ":p:h:t")
		-- now this line should never fail (because root_dir_name can not be nil)
		local workspace_dir = home .. "/.cache/jdtls-workspace/" .. root_dir_name

		local jdtls = require("jdtls")
		local config = {
			cmd = {
				vim.fn.expand("~/.sdkman/candidates/java/23-open/bin/java"),

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
				workspace_dir,
			},

			root_dir = root_dir_path,

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
						classpath = {
							includeUseClasspath = true, -- Add this to ensure classes are loaded
						},
						classFileContents = {
							enabled = true, -- Ensure class file contents are loaded when navigating
						},
					},
					references = {
						includeDecompiledSources = true,
					},
					implementationsCodeLens = {
						enabled = true,
					},
					referenceCodeLens = {
						enabled = true,
					},
					inlayHints = {
						parameterNames = {
							enabled = true,
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
		vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n"))

		config["init_options"] = {
			bundles = bundles,
		}

		jdtls.start_or_attach(config)
	end,
}
