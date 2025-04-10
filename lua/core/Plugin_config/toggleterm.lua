local M = {}

function M.config()
  require("toggleterm").setup {
    size = 15,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
  }

  -- Custom terminal functions
  local Terminal = require('toggleterm.terminal').Terminal

  -- Function to run current file based on filetype (excluding Java)
  local function run_file()
    local ft = vim.bo.filetype
    local filename = vim.fn.expand('%:p')
    local cmd = ''
    
    -- Skip Java files - they use the existing java_run module
    if ft == 'java' then
      -- Let the existing java_run.lua handle Java files
      return
    elseif ft == 'python' then
      cmd = 'python ' .. filename
    elseif ft == 'javascript' or ft == 'typescript' then
      cmd = 'node ' .. filename
    elseif ft == 'lua' then
      cmd = 'lua ' .. filename
    elseif ft == 'sh' then
      cmd = 'bash ' .. filename
    elseif ft == 'cpp' then
      -- Compile and run C++ file
      local output_file = vim.fn.fnamemodify(filename, ':r')
      cmd = 'g++ -o ' .. output_file .. ' ' .. filename .. ' && ' .. output_file
    end
    
    if cmd ~= '' then
      local run_term = Terminal:new({
        cmd = cmd,
        dir = "git_dir",
        direction = "horizontal",
        close_on_exit = false,
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
      })
      run_term:toggle()
    else
      print("Filetype '" .. ft .. "' not supported for running")
    end
  end

  -- Set up keymapping for non-Java files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {"python", "javascript", "typescript", "lua", "sh", "cpp"},
    callback = function()
      vim.keymap.set('n', '<F5>', run_file, {
        noremap = true,
        silent = true,
        buffer = true,
        desc = "Run file in terminal"
      })
    end
  })
end

return M
