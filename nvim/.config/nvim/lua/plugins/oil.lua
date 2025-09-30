local detail = false
return {
	{
		"stevearc/oil.nvim",
		enabled = false,
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			default_file_explorer = true,
			delete_to_trash = true,
			columns = {
				"icon",
				"size",
			},
			watch_for_changes = false,
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["gd"] = {
					desc = "Toggle file detail view",
					callback = function()
						detail = not detail
						if detail then
							require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
						else
							require("oil").set_columns({ "icon" })
						end
					end,
				},
			},
		},
		dependencies = { "nvim-mini/mini.icons" },
		lazy = false,

		keys = {
			{ "<leader>e", "<CMD>Oil --float<CR>", desc = "Open Oil" },
		},
	},
	{
		"benomahony/oil-git.nvim",
		dependencies = { "stevearc/oil.nvim" },
		enabled = false,
	},
	{
		"JezerM/oil-lsp-diagnostics.nvim",
		dependencies = { "stevearc/oil.nvim" },
		enabled = false,
	},
}
