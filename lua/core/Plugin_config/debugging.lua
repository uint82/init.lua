return {
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dap.adapters.python = {
            type = 'executable',
            command = 'python',  -- Adjust if using a virtualenv (e.g., 'venv/bin/python')
            args = { '-m', 'debugpy.adapter' },
            options = {
                source_filetype = 'python',
            },
        }

        dap.configurations.python = {
            {
                type = 'python',
                request = 'launch',
                name = 'Launch file',
                program = '${file}',  -- Runs the currently open file
                pythonPath = function()
                    -- Try to detect python path from active virtual environment
                    if vim.fn.executable(vim.fn.getcwd() .. '/venv/bin/python') == 1 then
                        return vim.fn.getcwd() .. '/venv/bin/python'
                    elseif vim.fn.executable(vim.fn.getcwd() .. '/.venv/bin/python') == 1 then
                        return vim.fn.getcwd() .. '/.venv/bin/python'
                    else
                        return 'python' -- Fallback to system Python
                    end
                end,
                console = 'integratedTerminal',  -- Keeps terminal open after execution
                justMyCode = false,
            },
        }

        dap.defaults.fallback.terminal_win_cmd = "belowright split | terminal"
        
        -- Setup dapui
        dapui.setup()
        
        -- Listeners to open and close dapui automatically
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end 
        

        -- Keymaps
        vim.keymap.set('n', '<leader>dt', function() dap.toggle_breakpoint() end)
        vim.keymap.set('n', '<leader>dc', function() dap.continue() end)
        vim.keymap.set('n', '<leader>do', function() dap.step_over() end)
        vim.keymap.set('n', '<leader>di', function() dap.step_into() end)
        vim.keymap.set('n', '<leader>dO', function() dap.step_out() end)
        vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
        vim.keymap.set('n', '<leader>dl', function() dap.run_last() end)
        vim.keymap.set('n', '<leader>xq', function() dap.close() dapui.close() end, 
        { desc = "Close Session" })
    end 
}
