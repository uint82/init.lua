require("core.plugin_config.gruvbox")
require("core.plugin_config.lualine")
require("core.plugin_config.nvim-tree")
require("core.plugin_config.telescope")
require("core.plugin_config.treesitter")
require("core.plugin_config.presence")
require("core.plugin_config.lsp-config")


local debugging = require('core.plugin_config.debugging')
debugging.config()  -- Execute the config function

-- Load dap-python configuration
local dap_python = require('core.plugin_config.dap-python')
dap_python.config()

-- Add this line with your other require statements
require("core.plugin_config.jdtls")

local java_run = require("core.plugin_config.java_run")
java_run.setup()

local toggleterm = require("core.plugin_config.toggleterm")
toggleterm.config()  -- Execute the config function
