return {
	{
		src = "https://github.com/supermaven-inc/supermaven-nvim",
		setup_name = "supermaven-nvim",
		opts = {

			keymaps = {
				accept_suggestion = "<Tab>",
				clear_suggestion = "<C-]>",
				accept_word = "<C-j>",
			},
			ignore_filetypes = { cpp = true }, -- or { "cpp", }
			color = {
				suggestion_color = "#333322", -- A darker gray instead of white (#ffffff)
				cterm = 244,
			},
			log_level = "off", -- set to "off" to disable logging completely
			disable_inline_completion = false, -- disables inline completion for use with cmp
			disable_keymaps = false, -- disables built in keymaps for more manual control
			condition = function()
				return false
			end,
		},
	},

	-- avante

	-- deps
	{

		src = "https://github.com/HakonHarnes/img-clip.nvim",
		setup_name = "img-clip",
		opts = {
			default = {
				embed_image_as_base64 = false,
				prompt_for_file_name = false,
				drag_and_drop = {
					insert_mode = true,
				},
				-- required for Windows users
				use_absolute_path = true,
			},
		},
	},

	-- avante main plugin
	{
		src = "https://github.com/yetone/avante.nvim",
		setup_name = "avante",
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		opts = {
			input = {
				provider = "native",
			},
			provider = "gemini",
			providers = {
				gemini = {
					endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
					model = "gemini-2.5-flash",
				},
			},
		},
		lazy = true,
	},
}
