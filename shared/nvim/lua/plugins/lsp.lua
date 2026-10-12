return {
  {
    "williamboman/mason.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "ts_ls", "svelte", "jdtls", "gopls" },
      })

      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Mapeos comunes al adjuntar un LSP
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil or client.name == "jdtls" then return end
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      -- NUEVO ESTÁNDAR PARA NEOVIM 0.11+
      -- Clangd
      vim.lsp.config('clangd', { capabilities = lsp_capabilities })
      vim.lsp.enable('clangd')
      
      -- TypeScript
      vim.lsp.config('ts_ls', { capabilities = lsp_capabilities })
      vim.lsp.enable('ts_ls')
      
      -- Go
      vim.lsp.config('gopls', {
        capabilities = lsp_capabilities,
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true, gofumpt = true, usePlaceholders = true,
            completeUnimported = true, semanticTokens = true,
          }
        }
      })
      vim.lsp.enable('gopls')

      -- Svelte
      vim.lsp.config('svelte', {
        capabilities = lsp_capabilities,
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts", "*.svelte" },
            callback = function(ctx)
              if client.name == 'svelte' then
                client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_bufnr(ctx.buf) })
              end
            end,
          })
        end,
      })
      vim.lsp.enable('svelte')
    end
  },

  -- SOPORTE JAVA (No usa lspconfig, se mantiene intacto)
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local function setup_jdtls()
        local jdtls = require("jdtls")
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
        local mason_path = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local config = {
          cmd = { mason_path, "-data", workspace_dir },
          root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle" }),
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>oi", jdtls.organize_imports, opts)
          end,
        }
        jdtls.start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = setup_jdtls,
      })
    end
  }
}
