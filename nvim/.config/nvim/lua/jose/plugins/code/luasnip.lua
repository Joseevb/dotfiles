return {
	"L3MON4D3/LuaSnip",
	dependencies = {
		-- Snippet Collections that LuaSnip should load
		"rafamadriz/friendly-snippets",
		"mlaursen/vim-react-snippets", -- Keep this here!
		-- Add other snippet collection plugins here if you use them
		-- {"path/to/your/custom-snippets"}
	},
	-- Load snippets when LuaSnip loads
	-- event = "VeryLazy", -- Or trigger on InsertEnter, or BufReadPost, etc.
	build = "make install_jsregexp", -- Keep build step if needed
	opts = {
		-- LuaSnip options (if any). Often defaults are fine.
		-- Example: history = true, updateevents = "TextChanged,TextChangedI"
	},
	config = function(_, opts)
		-- Configure LuaSnip (optional)
		require("luasnip").setup(opts)

		-- CRUCIAL: Load snippet collections
		-- This tells LuaSnip to load snippets from installed plugins like friendly-snippets
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Optional: Load snippets from your custom configuration directory
		-- Adjust the path as needed for your structure
		-- require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/lua/jose/snippets" })
		print("LuaSnip configured and snippets loaded.")

		-- Optional: Keymaps for jumping through snippet nodes (if not handled by blink)
		-- vim.keymap.set({"i", "s"}, "<C-L>", function() require("luasnip").jump(1) end, {silent = true})
		-- vim.keymap.set({"i", "s"}, "<C-H>", function() require("luasnip").jump(-1) end, {silent = true})
	end,
}
