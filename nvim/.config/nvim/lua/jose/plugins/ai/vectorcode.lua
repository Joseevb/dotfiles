return {
	"Davidyz/VectorCode",
	version = "*", -- optional, depending on whether you're on nightly or release
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "VectorCode", -- if you're lazy-loading VectorCode
	build = "pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
}
