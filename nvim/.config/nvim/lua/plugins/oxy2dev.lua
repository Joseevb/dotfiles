return {
	{
		"OXY2DEV/foldtext.nvim",
		lazy = false,
		opts = {
			condition = function()
				return true
			end,
			parts = {
				{
					kind = "section",
					output = function(_, window)
						local width = vim.api.nvim_win_get_width(window)
						local textoff = vim.fn.getwininfo(window)[1].textoff

						width = width - textoff

						local size = (vim.v.foldend - vim.v.foldstart) + 1
						local len = vim.fn.strdisplaywidth(" " .. tostring(size) .. " lines ")

						return {
							{ string.rep("-", math.ceil((width - len) / 2)), "@comment" },
							{ " " },
							{ tostring(size), "@number" },
							{ " lines ", "@comment" },
							{ string.rep("-", math.floor((width - len) / 2)), "@comment" },
						}
					end,
				},
			},
		},
	},

	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		priority = 49,
		opts = {},
	},
}
