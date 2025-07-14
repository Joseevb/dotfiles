-- Global Diagnostic UI Configuration: Defines how diagnostics look across all LSPs.
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl_group = "DiagnosticSign" .. type
	vim.fn.sign_define("LspDiagnostics" .. type, { text = icon, texthl = hl_group, numhl = hl_group })
end

-- Use vim.diagnostic.config directly
vim.diagnostic.config({
	virtual_text = { spacing = 4, severity_sort = true, source = "if_many" },
	signs = { active = signs }, -- Use defined signs
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { source = "if_many", border = "rounded" },
})

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "folke/neodev.nvim", opts = {} },
		"nvim-lua/plenary.nvim",
	},
}
