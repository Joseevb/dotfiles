return {
	"rcarriga/nvim-notify",
	opts = {
		render = "compact", -- Compact notification style
		timeout = 2000, -- Customize timeout in milliseconds
		stages = "slide", -- Animation style
		top_down = false, -- Notifications stack from bottom to top
		background_colour = "#1e1e1e", -- Set a custom background color (example: dark gray)
		on_open = function(win)
			-- Customize window position for bottom-right corner
			local win_opts = vim.api.nvim_win_get_config(win)
			win_opts.anchor = "SE" -- Anchor the notification to the bottom-right
			win_opts.row = vim.o.lines - 2 -- Adjust row to position above the command line
			win_opts.col = vim.o.columns - 2 -- Adjust column to fit within screen width
			vim.api.nvim_win_set_config(win, win_opts)
		end,
	},
	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)
		vim.notify = notify -- Set as default notify function
	end,
}
