-- Set termguicolors to enable true colors support
vim.opt.termguicolors = true

return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "macchiato", -- latte, frappe, macchiato, mocha
            background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
            enabled = false, -- dims the background color of inactive window
            shade = "dark",
            percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- force no italic
        no_bold = false, -- force no bold
        no_underline = false, -- force no underline
        styles = { -- handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- change the style of comments
        conditionals = { "italic" },
        loops = {"bold"},
        functions = {"italic"},
        keywords = {"italic"},
        strings = {},
        variables = {"bold"},
        numbers = {},
        booleans = {"bold"},
        properties = {},
        types = {"italic"},
        operators = {},
         },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- for more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
    })

    -- setup must be called before loading
    vim.cmd.colorscheme "catppuccin"
    end,
}
