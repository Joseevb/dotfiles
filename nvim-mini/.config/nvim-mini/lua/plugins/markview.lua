return {
	{
		src = "https://github.com/OXY2DEV/markview.nvim",
		setup_name = "markview",
		opts = {
			preview = {
				--- @type  "internal" | "mini" | "devicons"
				icon_provider = "mini", -- "mini" or "devicons"
			},
		},
	},
	{
		src = "https://github.com/OXY2DEV/helpview.nvim",
		setup_name = "helpview",
		opts = {
			preview = {
				--- @type  "internal" | "mini" | "devicons"
				icon_provider = "mini", -- "mini" or "devicons"
			},
			experimental = {
				check_rtp_message = false,
			},
		},
	},
}
