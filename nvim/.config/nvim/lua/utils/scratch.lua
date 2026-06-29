local M = {}

---Opens a scratch file of the specified filetype.
function M.open_scratch()
  vim.ui.input({ prompt = 'Scratch filetype (lua, py, etc): ' }, function(filetype)
    if not filetype or filetype == '' then
      return
    end

    local ft = filetype == 'md' and 'markdown' or filetype
    local timestamp = os.date '%Y%m%d%H%M%S'
    local directory = vim.fs.joinpath(vim.fn.stdpath 'cache', 'scratches')
    vim.fn.mkdir(directory, 'p')

    local filepath = vim.fs.joinpath(directory, 'scratch_' .. timestamp .. '.' .. filetype)
    vim.cmd { cmd = 'edit', args = { filepath } }
    vim.bo.filetype = ft
    vim.api.nvim_exec_autocmds('FileType', { buffer = 0, pattern = ft })

    vim.schedule(function()
      local ok, render_md = pcall(require, 'render-markdown')
      if ok and render_md.buf_enable then
        render_md.buf_enable()
      end
    end)
  end)
end

return M
