-- local function on_attach(_, bufnr)
-- 	local map = function(mode, lhs, rhs, desc)
-- 		vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true, buffer = bufnr, desc = desc })
-- 	end
--
-- 	map("n", "<leader>sd", function()
-- 		vim.diagnostic.open_float()
-- 	end, "Show Line Diagnostics")
--
-- 	-- JDTLS specific mappings
-- 	map("n", "<leader>co", require("jdtls").organize_imports, "Organize Imports")
--
-- 	map("n", "<leader>ev", function()
-- 		require("jdtls").extract_variable({ visual = false })
-- 	end, "Extract Variable")
-- 	map("v", "<leader>ev", function()
-- 		require("jdtls").extract_variable({ visual = true })
-- 	end, "Extract Variable (Visual)")
-- 	map("n", "<leader>ec", function()
-- 		require("jdtls").extract_constant({ visual = false })
-- 	end, "Extract Constant")
-- 	map("v", "<leader>ec", function()
-- 		require("jdtls").extract_constant({ visual = true })
-- 	end, "Extract Constant (Visual)")
--
-- 	map("n", "<leader>ei", require("jdtls").extract_interface, "Extract Interface")
-- 	map("n", "<leader>ee", require("jdtls").extract_enum, "Extract Enum")
-- 	map("n", "<leader>em", require("jdtls").extract_method, "Extract Method")
-- 	map("n", "<leader>ef", require("jdtls").extract_field, "Extract Field")
-- 	map("n", "<leader>el", require("jdtls").extract_local_variable, "Extract Local Variable")
-- 	map("n", "<leader>ek", require("jdtls").extract_class, "Extract Class")
-- 	map("n", "<leader>er", require("jdtls").rename_file, "Rename Compilation Unit")
-- 	map("n", "<leader>om", require("jdtls").open_main_class, "Open Main Class")
--
-- 	-- Other specific JDTLS commands
-- 	map("n", "<leader>jD", require("jdtls").resolve_dependency, "Resolve Dependency")
-- 	map("n", "<leader>jp", require("jdtls").project_root, "Show Project Root")
--
-- 	-- only call DAP after client is attached
-- 	require("jdtls.dap").setup_dap_main_class_configs()
-- 	map("n", "<leader>dt", require("jdtls").test_class, "Run test class")
-- 	map("n", "<leader>dn", require("jdtls").test_nearest_method, "Run test method")
-- end
--
-- -- lua/jose/plugins/code/lsp/java.lua
-- return {
-- 	"mfussenegger/nvim-jdtls",
-- 	ft = { "java" },
-- 	dependencies = {
-- 		"mfussenegger/nvim-dap",
-- 		"neovim/nvim-lspconfig",
-- 		"nvim-neotest/neotest",
-- 		"rcasia/neotest-java",
-- 		"rcarriga/nvim-dap-ui",
-- 		"JavaHello/spring-boot.nvim",
-- 	},
-- 	config = function()
-- 		require("jdtls").on_attach = on_attach
-- 	end,
-- }

local function get_sdkman_current_jdk_info()
	local java_home_path = vim.fn.getenv("JAVA_HOME")

	if java_home_path and vim.fn.isdirectory(java_home_path) == 1 then
		local java_version_output = vim.fn.system(java_home_path .. "/bin/java -version 2>&1")
		local major_version_match = java_version_output:match('version "%d+%.?%d*%.?%d*"')

		if major_version_match then
			local major_version = major_version_match:match('"(%d+)')
			if major_version then
				return {
					name = "JavaSE-" .. major_version,
					path = java_home_path,
					default = true,
				}
			end
		end
	end

	local default_java_path = vim.fn.exepath("java")
	if default_java_path and vim.fn.filereadable(default_java_path) == 1 then
		local java_version_output = vim.fn.system(default_java_path .. " -version 2>&1")
		local major_version_match = java_version_output:match('version "%d+%.?%d*%.?%d*"')
		if major_version_match then
			local major_version = major_version_match:match('"(%d+)')
			return {
				name = "JavaSE-" .. major_version,
				path = vim.fn.fnamemodify(default_java_path, ":h:h"),
				default = true,
			}
		end
	end

	return nil
end

local dynamic_java_runtime = get_sdkman_current_jdk_info()

local jdtls_runtimes = {}
if dynamic_java_runtime then
	table.insert(jdtls_runtimes, dynamic_java_runtime)
else
	table.insert(jdtls_runtimes, {
		name = "JavaSE-17",
		path = vim.fn.expand("~/.sdkman/candidates/java/17-open"),
		default = true,
	})
end

return {
	"https://github.com/Joseevb/nvim-java",
	opts = {

		jdk = {
			auto_install = false,
		},
	},

	config = function()
		vim.lsp.config("jdtls", {
			settings = {
				java = {
					configuration = {
						runtimes = jdtls_runtimes,
					},
				},
			},
		})
	end,
}
