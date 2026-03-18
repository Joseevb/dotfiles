local ok, jdtls = pcall(require, "jdtls")
if not ok then
	return
end

-- local home = os.getenv("HOME")
local mason_path = vim.fn.expand("$MASON") .. "/packages"
vim.print(vim.inspect(mason_path))
local bundles = {}
-- include dap and test jars
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/*.jar"), "\n"))
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(bundles, require("spring_boot").java_extensions())

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

jdtls.start_or_attach({
	settings = {
		java = {
			inlayHints = {
				parameterNames = {
					enabled = "all",
					-- you can also exclude `this`, etc
					exclusions = { "this" },
				},
			},
			signatureHelp = { enabled = true },
		},
	},
	cmd = {
		vim.fn.expand("$MASON/bin/jdtls"),
		"--jvm-arg=-javaagent:" .. mason_path .. "/jdtls/lombok.jar",
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
	init_options = { bundles = bundles },
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(bufnr, true)
		end
	end,
})
