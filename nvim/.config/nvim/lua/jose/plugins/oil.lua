return {
	"stevearc/oil.nvim",
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		columns = {
			"icon",
			"size",
		},
		delete_to_trash = true,
		view_options = {
			show_hidden = true,
		},
		sort = {
			"size",
			"asc",
		},
		float = {
			-- Padding around the floating window
			padding = 2,
			max_width = 0,
			max_height = 0,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
			-- optionally override the oil buffers window title with custom function: fun(winid: integer): string
			get_win_title = nil,
			-- preview_split: Split direction: "auto", "left", "right", "above", "below".
			preview_split = "auto",
			-- This is the config that will be passed to nvim_open_win.
			-- Change values here to customize the layout
			override = function(conf)
				return conf
			end,
		},
	},
}
