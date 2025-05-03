return {
    "oclay1st/maven.nvim",
    cmd = { "Maven", "MavenInit", "MavenExec" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {}, -- options, see default configuration
    keys = { { "<Leader>M", "<cmd>Maven<cr>", desc = "Maven" } },
}
