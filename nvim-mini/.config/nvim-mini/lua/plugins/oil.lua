local detail = false
return {
	{
		src = "https://github.com/stevearc/oil.nvim",
		setup_name = "oil",
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
	},
	{
		src = "https://github.com/benomahony/oil-git.nvim",
		setup_name = "oil-git",
		opts = {},
	},
	{
		src = "https://github.com/JezerM/oil-lsp-diagnostics.nvim",
		setup_name = "oil-lsp-diagnostics",
		opts = {},
	},
}
