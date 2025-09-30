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

	print("WARNING: SDKMAN: JAVA_HOME not set or version could not be determined. Falling back to system 'java'.")

	local default_java_path = vim.fn.exepath("java")
	if default_java_path and vim.fn.filereadable(default_java_path) == 1 then
		local java_version_output = vim.fn.system(default_java_path .. " -version 2>&1")
		local major_version_match = java_version_output:match('version "%d+%.?%d*%.?%d*"')
		if major_version_match then
			local major_version = major_version_match:match('"(%d+)')
			print(
				"SDKMAN: Fallback to system 'java' executable: " .. default_java_path .. ", version: " .. major_version
			)
			return {
				name = "JavaSE-" .. major_version,
				path = vim.fn.fnamemodify(default_java_path, ":h:h"),
				default = true,
			}
		end
	end

	print(
		"ERROR: SDKMAN: Could not determine any active or default Java runtime. Please ensure JDK is installed and JAVA_HOME is set."
	)
	return nil
end

local dynamic_java_runtime = get_sdkman_current_jdk_info()

local jdtls_runtimes = {}
if dynamic_java_runtime then
	table.insert(jdtls_runtimes, dynamic_java_runtime)
else
	print("WARNING: Using fallback JDTLS runtime config.")
	table.insert(jdtls_runtimes, {
		name = "JavaSE-17",
		path = vim.fn.expand("~/.sdkman/candidates/java/17-open"),
		default = true,
	})
end

return {
	{
		src = "https://github.com/mason-org/mason.nvim",
		setup_name = "mason",
		opts = {
			ensure_installed = {
				"jdtls",
				"java-debug-adapter",
				"java-test",
			},
		},
	},

	{ src = "https://github.com/neovim/nvim-lspconfig" },

	{ src = "https://github.com/nvim-java/nvim-java-refactor" },
	{ src = "https://github.com/nvim-java/lua-async-await" },
	{ src = "https://github.com/nvim-java/nvim-java-core" },
	{ src = "https://github.com/nvim-java/nvim-java-test" },
	{ src = "https://github.com/nvim-java/nvim-java-dap" },
	{
		src = "https://github.com/nvim-java/nvim-java",
		setup_name = "java",
		opts = {
			jdk = {
				auto_install = false,
			},
		},
		post_config = function()
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
	},

	{ src = "https://github.com/mason-org/mason-lspconfig.nvim", setup_name = "mason-lspconfig" },
	{
		src = "https://github.com/JavaHello/spring-boot.nvim",
		setup_name = "spring_boot",
	},
}
