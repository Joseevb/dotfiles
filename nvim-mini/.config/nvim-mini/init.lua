local config_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
local lua_path = config_path .. "/lua/?.lua;" .. config_path .. "/lua/?/init.lua"
if not package.path:find(lua_path, 1, true) then
	package.path = package.path .. ";" .. lua_path
end

require("plugins").setup()
require("set")
require("lsp")
require("maps")
require("autocmd")

-- colorscheme
vim.cmd.colorscheme("catppuccin")
