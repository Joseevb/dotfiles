local lsp_configurations = {
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				},
			},
		},
	},
	-- jdtls = {
	-- 	cmd = {
	-- 		"jdtls",
	-- 		"--jvm-arg=" .. string.format("-javaagent:%s", vim.fn.expand("$MASON/packages/lombok-nightly/lombok.jajkkk")),
	-- 	},
	-- 	init_options = {
	-- 		bundles = require("spring_boot").java_extensions(),
	-- 	},
	-- },
}

-- Custom configuration for LSPs
for server, config in pairs(lsp_configurations) do
	vim.lsp.config(server, config)
end
