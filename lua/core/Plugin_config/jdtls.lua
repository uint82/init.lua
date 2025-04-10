local M = {}

function M.config()
  local jdtls_ok, jdtls = pcall(require, "jdtls")
  if not jdtls_ok then
    vim.notify("JDTLS not found, skipping configuration", vim.log.levels.WARN)
    return
  end

  -- Find root directory (usually the maven or gradle project root)
  local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
  local root_dir = require("jdtls.setup").find_root(root_markers)
  if not root_dir then
    return
  end

  -- Get the data directory for the project
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

  -- Get the mason jdtls path
  local mason_registry = require("mason-registry")
  local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
  
  -- Find the proper launcher jar file based on OS
  local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  
  -- Java executable
  local java_cmd = "java"
  
  -- JDTLS config directory based on OS
  local config_dir
  if vim.fn.has("win32") == 1 then
    config_dir = jdtls_path .. "/config_win"
  elseif vim.fn.has("mac") == 1 then
    config_dir = jdtls_path .. "/config_mac"
  else
    config_dir = jdtls_path .. "/config_linux"
  end

  -- Setup JDTLS config
  local config = {
    cmd = {
      java_cmd,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-jar", launcher_jar,
      "-configuration", config_dir,
      "-data", workspace_dir,
    },
    
    root_dir = root_dir,
    
    settings = {
      java = {
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*"
          },
          filteredTypes = {
            "com.sun.*",
            "io.micrometer.shaded.*",
            "java.awt.*",
            "jdk.*",
            "sun.*",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
          },
          hashCodeEquals = {
            useJava7Objects = true,
          },
          useBlocks = true,
        },
        configuration = {
          runtimes = {
            {
              name = "JavaSE-23",
              path = "C:/ProgramFiles/Java/jdk-23", -- Update with your Java path
            },
          },
        },
      },
    },
    
    on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      
      -- Mappings
      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
      vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
      vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
      vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, bufopts)
      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

      vim.keymap.set('n', '<F5>', function() require('jdtls').run_main() end, bufopts)
      
      -- Java specific mappings
      if client.name == "jdtls" then
        -- Code generation
        vim.keymap.set('n', '<A-o>', jdtls.organize_imports, bufopts)
        vim.keymap.set('n', '<leader>ev', jdtls.extract_variable, bufopts)
        vim.keymap.set('v', '<leader>ev', function() jdtls.extract_variable(true) end, bufopts)
        vim.keymap.set('n', '<leader>ec', jdtls.extract_constant, bufopts)
        vim.keymap.set('v', '<leader>ec', function() jdtls.extract_constant(true) end, bufopts)
        vim.keymap.set('v', '<leader>em', function() jdtls.extract_method(true) end, bufopts)
      end
    end,
    
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  }
  
  -- Start JDTLS
  jdtls.start_or_attach(config)
end

-- Auto-setup for Java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    M.config()
  end,
})

return M
