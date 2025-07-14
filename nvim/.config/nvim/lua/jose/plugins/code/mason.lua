local servers = {

	lua_ls = {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				diagnostics = { globals = { "vim" } },
				telemetry = { enable = false },
			},
		},
	},
	ts_ls = {
		settings = {
			typescript = { preferences = { importModuleSpecifierPreference = "relative" } },
			javascript = { preferences = { importModuleSpecifierPreference = "relative" } },
		},
		-- keys = {
		-- 	{
		-- 		"<leader>rn",
		-- 		function()
		-- 			vim.lsp.buf.execute_command({
		-- 				command = "_typescript.organizeImports",
		-- 				arguments = { vim.fn.expand("%:p") },
		-- 			})
		-- 		end,
		-- 		desc = "Rename",
		-- 		on_attach = function(_, bufnr)
		-- 			local bufmap = function(mode, lhs, rhs, desc)
		-- 				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		-- 			end
		--
		-- 			bufmap("n", "<leader>co", function()
		-- 				vim.lsp.buf.execute_command({
		-- 					command = "_typescript.organizeImports",
		-- 					arguments = { vim.fn.expand("%:p") },
		-- 				})
		-- 			end, "Organize Imports")
		-- 		end,
		-- 	},
		-- },
	},
	eslint = {}, -- Basic setup, will inherit base on_attach
	emmet_language_server = {
		filetypes = { -- Ensure all relevant types are listed
			"html",
			"css",
			"scss",
			"less",
			"sass", -- Styles
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact", -- JS/TS/React
			"vue",
			"svelte",
			"astro",
			"php",
			"twig", -- Frameworks/Templating
			"xml",
			"xsl", -- XML related
		},
		init_options = { preferences = { includeLanguages = { javascript = "javascriptreact" } } },
	},
	tailwindcss = {
		settings = {
			tailwindcss = {
				validate = true,
				-- Uncomment and configure linting rules as needed
				-- lint = {
				-- 	cssConflict = "warning",
				-- 	invalidApply = "error",
				-- 	invalidConfigPath = "error",
				-- 	invalidScreen = "error",
				-- 	invalidTailwindDirective = "error",
				-- 	invalidVariant = "error",
				-- 	recommendedVariantOrder = "error",
				-- 	unrecognizedAtDirective = "error",
				-- 	unrecognizedScreen = "error",
				-- 	unrecognizedVariant = "error",
				-- },
			},
		},
	},
	bashls = {},
	dockerls = {},
	yamlls = {},
	pyright = {},
	intelephense = {},
	clangd = {},
	biome = {},
	html = {},
	cssls = {},
	jsonls = {},
	rust_analyzer = {},
	-- Add any other servers you need here
}
local server_names = {}

for k, v in pairs(servers) do
	table.insert(server_names, k)
	if type(v) == "table" and next(v) then
		vim.lsp.config(k, v)
		print("Mason: Configuring " .. k .. " with options: " .. vim.inspect(v))
	end
end

return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		{
			"williamboman/mason.nvim",
			opts = {},
		},
	},
	lazy = false,
	opts = {
		ensure_installed = server_names,
		automatic_installation = true,
		automatic_enable = {
			exclude = { "jdtls" },
		},
	},
	keys = {
		{
			"<leader>rn",
			function()
				vim.lsp.buf.rename()
			end,
			desc = "Rename",
		},
		{
			"<leader>ca",
			function()
				vim.lsp.buf.code_action()
			end,
			desc = "Code Action",
		},
		{
			"<leader>cA",
			function()
				vim.lsp.buf.code_action({
					context = {
						only = {
							"source",
						},
						diagnostics = {},
					},
				})
			end,
			desc = "Source Action",
		},
		{
			"<leader>sd",
			function()
				vim.diagnostic.open_float()
			end,
			desc = "Show Line Diagnostics",
		},
		{
			"gr",
			function()
				vim.lsp.buf.references()
			end,
			desc = "Go to References",
		},
		{
			"<C-k>",
			function()
				vim.lsp.buf.signature_help()
			end,
			desc = "Signature Help",
		},
	},
}
