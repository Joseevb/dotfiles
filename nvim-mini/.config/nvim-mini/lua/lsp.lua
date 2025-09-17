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
	emmet_language_server = {
		filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
}

-- Custom configuration for LSPs
for server, config in pairs(lsp_configurations) do
	vim.lsp.config(server, config)
end
