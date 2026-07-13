local M = {}

local loaded_modules = {}

local startup_modules = {
	'plugins.ui.catppuccin',
	'plugins.editor.terminal',
	'plugins.editor.mini',
	'plugins.editor.grug',
	'plugins.editor.markdown_renderer',
	'plugins.editor.treesitter',
	'plugins.editor.visual-whitespace',
	'plugins.editor.quicker',
	'plugins.git.git',
	'plugins.ai.opencode',
	'plugins.ai.supermaven',
	'plugins.lsp.lazydev',
	'plugins.lsp.lsp',
	'plugins.lsp.dap',
	'plugins.lsp.java',
	'plugins.lsp.sonar_qube',
	'plugins.ai.lite_ui',
}

local function load_module(module)
	if loaded_modules[module] then
		return true
	end

	local ok, err = pcall(require, module)
	if not ok then
		vim.notify('Failed to load ' .. module .. ': ' .. err, vim.log.levels.ERROR)
		return false
	end

	loaded_modules[module] = true
	return true
end

function M.setup()
	for _, module in ipairs(startup_modules) do
		load_module(module)
	end
end

return M
