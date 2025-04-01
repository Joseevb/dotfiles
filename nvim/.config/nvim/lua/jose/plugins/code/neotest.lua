return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "rcasia/neotest-java",
    },
    opts = {
        adapters = {
            ["neotest-java"] = {
                junit_jar = nil, -- default: stdpath("data") .. /nvim/neotest-java/junit-platform-console-standalone-[version].jar
                incremental_build = true,
            },
        },
    },
}
