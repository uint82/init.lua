local M = {}

function M.setup()
  -- Function to compile and run Java file
  local function compile_and_run_java()
    local file = vim.fn.expand('%:p')
    local file_name_no_ext = vim.fn.expand('%:t:r')
    local dir = vim.fn.expand('%:p:h')
    
    -- Check if Java Output buffer already exists
    local existing_buf = -1
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):match("Java Output$") then
        existing_buf = buf
        break
      end
    end
    
    local buf
    if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
      -- Reuse existing buffer
      buf = existing_buf
      -- Find and focus the window with this buffer
      local found_win = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_set_current_win(win)
          found_win = true
          break
        end
      end
      -- If buffer exists but has no window, open it in a new split
      if not found_win then
        vim.cmd('belowright split')
        vim.api.nvim_win_set_buf(0, buf)
      end
      -- Clear the buffer
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
    else
      -- Create a new buffer
      vim.cmd('belowright new')
      buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(buf, 'Java Output')
      vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
      
      -- Add 'q' keybinding to close the buffer
      vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {noremap = true, silent = true})
    end
    
    -- Clean any output lines
    local function clean_output_lines(data)
      if data[1] == "" and #data <= 1 then
        return {}
      end
      
      local cleaned_data = {}
      for _, line in ipairs(data) do
        if line ~= "" or #data > 1 then
          -- Remove carriage returns that might appear as "^M"
          local cleaned_line = line:gsub("\r", "")
          table.insert(cleaned_data, cleaned_line)
        end
      end
      return cleaned_data
    end
    
    -- Compile the Java file
    local compile_cmd = 'javac -d "' .. dir .. '" "' .. file .. '"'
    local compile_job = vim.fn.jobstart(compile_cmd, {
      on_stdout = function(_, data)
        local cleaned_data = clean_output_lines(data)
        if #cleaned_data > 0 then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, cleaned_data)
        end
      end,
      on_stderr = function(_, data)
        local cleaned_data = clean_output_lines(data)
        if #cleaned_data > 0 then
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, cleaned_data)
        end
      end,
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          -- Compilation successful, run the class file
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Compilation successful, running program...", ""})
          
          local run_cmd = 'java -cp "' .. dir .. '" ' .. file_name_no_ext
          vim.fn.jobstart(run_cmd, {
            on_stdout = function(_, data)
              local cleaned_data = clean_output_lines(data)
              if #cleaned_data > 0 then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, cleaned_data)
              end
            end,
            on_stderr = function(_, data)
              local cleaned_data = clean_output_lines(data)
              if #cleaned_data > 0 then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, cleaned_data)
              end
            end,
            on_exit = function(_, run_exit_code)
              if run_exit_code == 0 then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"", "Program completed successfully."})
              else
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"", "Program exited with code " .. run_exit_code})
              end
            end
          })
        else
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"", "Compilation failed with exit code " .. exit_code})
        end
      end
    })
  end
  
  -- Set up keybinding for Java files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
      vim.keymap.set('n', '<F5>', compile_and_run_java, {
        noremap = true,
        silent = true,
        buffer = true,
        desc = "Compile and run Java file"
      })
    end
  })
end

return M
