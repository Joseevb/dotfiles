return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.5",
	-- or                            , branch = '0.1.x',
	dependencies = { { "nvim-lua/plenary.nvim" } },
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, {})

		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		vim.keymap.set("n", "<C-g>", builtin.git_files, {})

		vim.keymap.set("n", "<leader>fw", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>fW", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>fg", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)
	end,
}
