return {
	"JavaHello/spring-boot.nvim",
	ft = "java",
	dependencies = {
		"mfussenegger/nvim-jdtls", -- or nvim-java, nvim-lspconfig
		"ibhagwan/fzf-lua", -- optional
	},
	opts = {
		ls_path = "/mnt/c/Users/joseesteban.vasquez/.vscode/extensions/vmware.vscode-spring-boot-1.63.0/language-server/",
		jdtls_name = "jdtls",
		log_file = vim.fn.stdpath("cache") .. "/spring-boot.log",
	},
}
