-- lua/jose/lsp/handlers.lua

local M = {}

M.map_lsp_key = function(bufnr, mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = bufnr, desc = "LSP: " .. (desc or "") })
end

M.on_attach_base = function(_, bufnr)
	local map_lsp_key = M.map_lsp_key

	-- Common LSP Mappings
	map_lsp_key(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename")
	map_lsp_key(bufnr, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	map_lsp_key(bufnr, "n", "K", function()
		local winid = require("ufo").peekFoldedLinesUnderCursor()
		if not winid then
			vim.lsp.buf.hover()
		end
	end, "Hover")

	map_lsp_key(bufnr, "n", "<leader>sd", vim.diagnostic.open_float, "Show Line Diagnostics")
	map_lsp_key(bufnr, "n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, "Go to Previous Diagnostic")
	map_lsp_key(bufnr, "n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, "Go to Next Diagnostic")

	-- Include any other base keymaps you want here, e.g., navigation
	-- map_lsp_key(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
	-- map_lsp_key(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to Definition")
	-- map_lsp_key(bufnr, "n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
	-- map_lsp_key(bufnr, "n", "gr", vim.lsp.buf.references, "Go to References")
	-- map_lsp_key(bufnr, "n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
end

return M
