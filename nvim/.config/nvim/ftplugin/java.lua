local ok, jdtls = pcall(require, "jdtls")
if not ok then
	return
end

-- local home = os.getenv("HOME")
local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = {}
-- include dap and test jars
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-debug-adapter/extension/server/*.jar"), "\n"))
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(bundles, require("spring_boot").java_extensions())

jdtls.start_or_attach({
	cmd = {
		vim.fn.expand("$HOME/.local/share/nvim/mason/bin/jdtls"),
		"--jvm-arg=-javaagent:" .. mason_path .. "/jdtls/lombok.jar",
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
	init_options = { bundles = bundles },
	capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
})
