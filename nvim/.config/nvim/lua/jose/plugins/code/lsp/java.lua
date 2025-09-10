local function on_attach(_, bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = bufnr, desc = desc })
	end

	map("n", "<leader>sd", function()
		vim.diagnostic.open_float()
	end, "Show Line Diagnostics")

	-- JDTLS specific mappings
	map("n", "<leader>co", require("jdtls").organize_imports, "Organize Imports")

	map("n", "<leader>ev", function()
		require("jdtls").extract_variable({ visual = false })
	end, "Extract Variable")
	map("v", "<leader>ev", function()
		require("jdtls").extract_variable({ visual = true })
	end, "Extract Variable (Visual)")
	map("n", "<leader>ec", function()
		require("jdtls").extract_constant({ visual = false })
	end, "Extract Constant")
	map("v", "<leader>ec", function()
		require("jdtls").extract_constant({ visual = true })
	end, "Extract Constant (Visual)")

	map("n", "<leader>ei", require("jdtls").extract_interface, "Extract Interface")
	map("n", "<leader>ee", require("jdtls").extract_enum, "Extract Enum")
	map("n", "<leader>em", require("jdtls").extract_method, "Extract Method")
	map("n", "<leader>ef", require("jdtls").extract_field, "Extract Field")
	map("n", "<leader>el", require("jdtls").extract_local_variable, "Extract Local Variable")
	map("n", "<leader>ek", require("jdtls").extract_class, "Extract Class")
	map("n", "<leader>er", require("jdtls").rename_file, "Rename Compilation Unit")
	map("n", "<leader>om", require("jdtls").open_main_class, "Open Main Class")

	-- Other specific JDTLS commands
	map("n", "<leader>jD", require("jdtls").resolve_dependency, "Resolve Dependency")
	map("n", "<leader>jp", require("jdtls").project_root, "Show Project Root")

	-- only call DAP after client is attached
	require("jdtls.dap").setup_dap_main_class_configs()
	map("n", "<leader>dt", require("jdtls").test_class, "Run test class")
	map("n", "<leader>dn", require("jdtls").test_nearest_method, "Run test method")
end

-- lua/jose/plugins/code/lsp/java.lua
return {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	dependencies = {
		"mfussenegger/nvim-dap",
		"neovim/nvim-lspconfig",
		"nvim-neotest/neotest",
		"rcasia/neotest-java",
		"rcarriga/nvim-dap-ui",
		"JavaHello/spring-boot.nvim",
	},
	config = function()
		require("jdtls").on_attach = on_attach
	end,
}
