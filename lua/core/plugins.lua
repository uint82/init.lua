local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local plugins = {
  'ellisonleao/gruvbox.nvim',
  'nvim-tree/nvim-tree.lua',
  'nvim-tree/nvim-web-devicons',
  'nvim-lualine/lualine.nvim',
  'nvim-treesitter/nvim-treesitter',
  'andweeb/presence.nvim',
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    'mfussenegger/nvim-dap',
     dependencies = { {'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio'} }
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
  },
  ft = "python",  -- Only load for Python files
  },
  {
    'nvim-telescope/telescope.nvim',
     tag = '0.1.8',
     dependencies = { {'nvim-lua/plenary.nvim'} }
  },
  "mfussenegger/nvim-jdtls",
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls",  -- Make sure Mason installs jdtls
      }
    }
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = true
  }
}


local opts = {}

require("lazy").setup(plugins, opts)
