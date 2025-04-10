-- Require and setup Mason
require("mason").setup()

-- Require and setup mason-lspconfig
require("mason-lspconfig").setup({
  -- A list of servers to automatically install if they're not already installed
  ensure_installed = {
    "lua_ls", "pyright", "jdtls",
    -- Add the language servers you want to auto-install here
    -- Examples: "lua_ls", "pyright", "tsserver", "rust_analyzer"
  },
  -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed
  automatic_installation = true,
})

-- Configure LSP servers
local lspconfig = require('lspconfig')

-- Configure lua_ls to recognize Neovim globals
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        -- Limit runtime file scanning
        library = {
          vim.env.VIMRUNTIME,
          -- Explicitly add only necessary runtime paths
          vim.fn.stdpath('config'),
          vim.fn.stdpath('data') .. '/site/pack/packer/opt',
          vim.fn.stdpath('data') .. '/site/pack/packer/start',
        },
        maxPreload = 100,     -- Limit number of files to preload
        preloadFileSize = 50, -- Limit size of files to preload
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
  -- Capabilities to reduce unnecessary scanning
  capabilities = (function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
    return capabilities
  end)(),
}

-- Configure Pyright for real-time diagnostics
lspconfig.pyright.setup {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        diagnosticMode = "workspace",
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
        },
        -- Limit directories to scan
        extraPaths = {},
        ignore = {
          -- Ignore large directories
          "**/node_modules/**",
          "**/.git/**",
          "**/build/**",
          "**/dist/**",
        },
      },
    },
  },
  flags = {
    debounce_text_changes = 150,
  },
}

-- Example setup for a few language servers
-- Uncomment and modify as needed:
-- lspconfig.lua_ls.setup {}
-- lspconfig.pyright.setup {}
-- lspconfig.tsserver.setup {}
-- lspconfig.rust_analyzer.setup {}

-- Set up diagnostic configuration for real-time feedback
vim.diagnostic.config({
  virtual_text = true,       -- Show diagnostics as virtual text
  signs = true,              -- Show signs in the sign column
  underline = true,          -- Underline text with issues
  update_in_insert = false,   -- Update diagnostics in insert mode
  severity_sort = true,      -- Sort diagnostics by severity
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "if_many",
    header = "",
    prefix = "",
  },
})

-- Add key mappings for LSP functionality
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, {})


-- Additional convenient keymaps for diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
