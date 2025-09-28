local config_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local lua_path = config_path .. "/lua/?.lua;" .. config_path .. "/lua/?/init.lua"
if not package.path:find(lua_path, 1, true) then
	package.path = package.path .. ";" .. lua_path
end

_G.CONFIG_PATH = config_path

require("plugins").setup()

vim.schedule(function()
	require("set")
	require("lsp")
	require("maps")
	require("autocmd")
	vim.o.showtabline = 2
end)

-- colorscheme
vim.cmd.colorscheme("catppuccin")
require("mini.tabline")
