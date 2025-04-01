return {
    "dimfred/resize-mode.nvim",
    -- additional configurations if necessary
    opts = {
        horizontal_amount = 9,
        vertical_amount = 5,
        quit_key = "<ESC>",
        enable_mapping = true,
        resize_keys = {
            "h", -- increase to the left
            "j", -- increase to the bottom
            "k", -- increase to the top
            "l", -- increase to the right
            "H", -- decrease to the left
            "J", -- decrease to the bottom
            "K", -- decrease to the top
            "L", -- decrease to the right
        },
        hooks = {
            on_enter = nil, -- called when entering resize mode
            on_leave = nil, -- called when leaving resize mode
        },
    },
    config = function()
        local resize = require("resize-mode")

        vim.keymap.set("n", "<C-w>R", function()
            resize.start()
        end, { silent = true })
    end,
}
