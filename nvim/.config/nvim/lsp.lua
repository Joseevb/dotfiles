vim.pack.add {
	pkg 'neovim/nvim-lspconfig',
	pkg 'mason-org/mason.nvim',
	pkg 'mason-org/mason-lspconfig.nvim',
	pkg 'dmmulroy/ts-error-translator.nvim',
	pkg 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

require 'mason'.setup {}

local project_config = require 'project_config'
local map = vim.keymap.set

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			diagnostics = {
				globals = {
					'vim',
					'get_project_flag',
					'set_project_flags',
				},
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file('', true),
			},
			format = {
				enable = true,
				defaultConfig = {
					call_arg_parentheses = 'remove',
					quote_style = 'single',
				},
			},
		},
	},
})

vim.lsp.config('spectral', {
	root_markers = {
		'.spectral.yaml',
		'.spectral.yml',
		'openapi.yaml',
		'openapi.yml',
		'openapi-rest.yml',
		'openapi.json',
		'.git',
	},
})

require 'mason-lspconfig'.setup {
	ensure_installed = { 'lua_ls', 'tsgo', 'jdtls' },
	automatic_enable = {
		exclude = { 'jdtls' },
	},
}

require 'mason-tool-installer'.setup {
	ensure_installed = {
		'yaml-language-server',
		'spectral-language-server',
		'vacuum',
	},
}

vim.diagnostic.config {
	float = true,
	virtual_text = {
		prefix = '●', -- or '■', '▎', '✗', whatever icon you want
		spacing = 4,
		source = 'if_many', -- Show source if multiple LSPs
	},
}

--- Completions
-- vim.o.autocomplete = true
-- vim.o.pumborder = 'rounded'
--
-- vim.o.autocomplete = true
-- vim.o.autocompletedelay = 120
--
-- vim.o.complete = 'o'
-- vim.o.completeopt = 'fuzzy,menuone,noselect'
-- vim.o.pumborder = 'rounded'
-- vim.o.pumheight = 7
-- vim.o.pummaxwidth = 40
-- vim.o.pumheight = 7
-- vim.o.pummaxwidth = 40

-- Format function that takes buffer as parameter
local function format(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local project_formatter = project_config.get_flag 'project_formatter'

	if project_formatter then
		-- Find that specific client
		for _, c in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
			if c.name == project_formatter and c:supports_method('textDocument/formatting', bufnr) then
				vim.lsp.buf.format { id = c.id, bufnr = bufnr }
				return
			end
		end
	end
	-- Default: use any formatter
	vim.lsp.buf.format { bufnr = bufnr }
end

local format_group = vim.api.nvim_create_augroup('UserLspFormat', { clear = false })
local highlight_group = vim.api.nvim_create_augroup('UserLspDocumentHighlight', { clear = false })

local function format_range()
	vim.lsp.buf.format {
		range = {
			start = vim.api.nvim_buf_get_mark(0, '<'),
			['end'] = vim.api.nvim_buf_get_mark(0, '>'),
		},
	}
end

local function toggle_inlay_hints(bufnr)
	local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
end

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end

		local opts = { buffer = ev.buf, silent = true }
		local function buf_map(mode, lhs, rhs, desc)
			map(mode, lhs, rhs, vim.tbl_extend('force', opts, { desc = desc }))
		end

		buf_map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
		buf_map('n', '<leader>f', function()
			format(ev.buf)
		end, 'Format buffer')
		buf_map('x', '<leader>f', format_range, 'Format selection')

		buf_map('i', '<C-s>', function()
			if vim.fn.pumvisible() == 1 then
				vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes('<C-e>', true, false, true),
					'n',
					false
				)
			end

			vim.schedule(function()
				vim.lsp.buf.signature_help {
					border = 'rounded',
					focusable = false,
					max_width = 80,
				}
			end)
		end, 'Signature help')

		if client:supports_method('textDocument/documentHighlight', ev.buf) then
			vim.api.nvim_clear_autocmds {
				group = highlight_group,
				buffer = ev.buf,
			}

			vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				group = highlight_group,
				buffer = ev.buf,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				group = highlight_group,
				buffer = ev.buf,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd('LspDetach', {
				group = highlight_group,
				buffer = ev.buf,
				once = true,
				callback = function(args)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds {
						group = highlight_group,
						buffer = args.buf,
					}
				end,
			})
		end

		if client:supports_method('textDocument/inlayHint', ev.buf) then
			buf_map('n', '<leader>uh', function()
				toggle_inlay_hints(ev.buf)
			end, 'Toggle inlay hints')
		end

		if
				client:supports_method('textDocument/formatting', ev.buf)
				and project_config.get_flag('project_format_on_save', true)
		then
			vim.api.nvim_clear_autocmds {
				group = format_group,
				buffer = ev.buf,
			}

			vim.api.nvim_create_autocmd('BufWritePre', {
				group = format_group,
				buffer = ev.buf,
				callback = function()
					format(ev.buf)
				end,
			})
		end
	end,
})

require 'ts-error-translator'.setup {
	auto_attach = true,

	servers = {
		'astro',
		'svelte',
		'ts_ls',
		'oxlint',
		'tsgo',
		'typescript-tools',
		'volar',
		'vtsls',
	},
}

-- LSP Diagnostics on quickfix
-- Diagnostic icons
local icons = {
	[vim.diagnostic.severity.ERROR] = '✗', -- or '✗', '󰯆'
	[vim.diagnostic.severity.WARN] = '⚠', -- or '⚠', '󰀦'
	[vim.diagnostic.severity.INFO] = '󰋼', -- or 'ℹ', '󰋼'
	[vim.diagnostic.severity.HINT] = '󰌶', -- or '💡', '󰌵'
}

-- Pretty diagnostics in quickfix with icons
local function pretty_setqflist(opts)
	opts = opts or {}

	local diagnostics = vim.diagnostic.get(opts.bufnr, {
		severity = opts.severity,
	})

	local items = {}
	for _, d in ipairs(diagnostics) do
		local icon = icons[d.severity] or '●'
		table.insert(items, {
			bufnr = d.bufnr,
			lnum = d.lnum + 1,
			col = d.col + 1,
			text = string.format('%s %s', icon, d.message),
			type = d.severity == vim.diagnostic.severity.ERROR and 'E'
					or d.severity == vim.diagnostic.severity.WARN and 'W'
					or d.severity == vim.diagnostic.severity.INFO and 'I'
					or 'H',
		})
	end

	vim.fn.setqflist(items, 'r')
	vim.cmd 'copen'
end

local function pretty_setloclist(opts)
	opts = opts or {}

	local diagnostics = vim.diagnostic.get(opts.bufnr or 0, {
		severity = opts.severity,
	})

	local items = {}
	for _, d in ipairs(diagnostics) do
		local icon = icons[d.severity] or '●'
		table.insert(items, {
			bufnr = d.bufnr,
			lnum = d.lnum + 1,
			col = d.col + 1,
			text = string.format('%s %s', icon, d.message),
			type = d.severity == vim.diagnostic.severity.ERROR and 'E'
					or d.severity == vim.diagnostic.severity.WARN and 'W'
					or d.severity == vim.diagnostic.severity.INFO and 'I'
					or 'H',
		})
	end

	vim.fn.setloclist(0, items, 'r')
	vim.cmd 'lopen'
end

--- Maps

--- Error (mimicks Trouble with a quickfix/location list)
map('n', '<leader>xx', function()
	pretty_setqflist {}
end, { desc = 'All diagnostics (QF)' })

map('n', '<leader>xX', function()
	pretty_setqflist { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Only errors (QF)' })

map('n', '<leader>xl', function()
	pretty_setloclist { bufnr = 0 }
end, { desc = 'Buffer diagnostics (loclist)' })
