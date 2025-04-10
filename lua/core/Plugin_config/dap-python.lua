return {
  config = function()
    local dap_python = require("dap-python")
    -- Use your system Python or specify a path
    dap_python.setup("python")
    
    -- Add test configurations
    dap_python.test_runner = "pytest"
    
    -- Additional keymaps if needed
    vim.keymap.set("n", "<leader>dpr", function() dap_python.test_method() end, { desc = "Debug Python Method" })
    vim.keymap.set("n", "<leader>dpc", function() dap_python.test_class() end, { desc = "Debug Python Class" })
  end
}
