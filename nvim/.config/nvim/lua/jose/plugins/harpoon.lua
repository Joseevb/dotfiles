return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	opts = {},
	keys = {
		-- Use the defined local variables inside the functions
		{
			"<leader>a",
			function()
				require("harpoon"):list():add()
				vim.notify("Harpooned file: " .. vim.fn.expand("%:p"), vim.log.levels.INFO)
			end,
			desc = "Harpoon Add File",
		},
		{
			"<C-e>",
			function()
				-- Telescope loading might be better kept inside pcall for safety
				local telescope_ok, telescope = pcall(require, "telescope")
				if not telescope_ok then
					vim.notify("Telescope not loaded", vim.log.levels.ERROR)
					return
				end
				-- Ensure harpoon extension is loaded before calling
				pcall(require("telescope").load_extension, "harpoon")
				-- Check if the extension exists before calling (extra safety)
				if telescope.extensions and telescope.extensions.harpoon and telescope.extensions.harpoon.marks then
					telescope.extensions.harpoon.marks()
				else
					vim.notify("Telescope harpoon extension not available", vim.log.levels.ERROR)
					-- Maybe fallback to the regular UI?
					-- require("harpoon").toggle_quick_menu()
				end
			end,
			desc = "Harpoon Marks (Telescope)",
		},

		-- Navgation: Use the local require("harpoon") variable
		{
			"<C-A-h>",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "Harpoon File 1",
		},
		{
			"<C-A-j>",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "Harpoon File 2",
		},
		{
			"<C-A-k>",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "Harpoon File 3",
		},
		{
			"<C-A-l>",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "Harpoon File 4",
		},

		-- Prev/Next: Use the local require("harpoon") variable
		{
			"<C-S-P>",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Harpoon Previous",
		},
		{
			"<C-S-N>",
			function()
				require("harpoon"):list():next()
			end,
			desc = "Harpoon Next",
		},

		-- Harpoon UI Menu: Use the local require("harpoon") variable
		{
			"<leader>hm",
			function()
				local harpoon = require("harpoon")
				harpoon.ui.toggle_quick_menu(harpoon:list())
			end,
			desc = "Harpoon Menu",
		},
	},
}
