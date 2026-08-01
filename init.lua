-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)
vim.api.nvim_set_keymap('n', '<space>w', ':w<CR>', { noremap = true, silent = true })

-- Opciones base
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.g.mapleader = " "

require("lazy").setup({

  -- 1. THEME (Monokai Pro - filtro "pro" = variante gris/clásica)
  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
        styles = {
          comment = { italic = true },
          keyword = { italic = true },
          type = { italic = true },
          storageclass = { italic = true },
          structure = { italic = true },
          parameter = { italic = true },
          annotation = { italic = true },
          tag_attribute = { italic = true },
        },
        filter = "pro", -- pro | octagon | machine | ristretto | spectrum | classic
        background_clear = {},
      })
      vim.opt.background = "dark"
      vim.cmd.colorscheme("monokai-pro")
    end
  },

  -- Temas anteriores
  { "nyoom-engineering/oxocarbon.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },

  -- 2. DASHBOARD
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠠⡀⠀⠀⠀⠠⡀⠀⢄⠀⠀⡐⢀⡀⠀⠀⠀⡄⣦⠀⠀⠆⠰⢀⠀⠀⠐⠀⣠⢂⠒⠀⠀⠀⠀⠀⣠⠔⠂⠀",
        "⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠁⠀⠀⢐⠀⠀⡇⢸⠀⠀⣃⢸⡆⠀⡄⢠⠰⡜⡇⠀⠀⠆⢁⠀⢰⠀⡐⠀⠌⠀⠀⠀⠀⠀⠈⢀⠄⠀⠀",
        "⠀⠀⠀⠀⠀⠀⢀⣤⡀⡀⠀⠀⠀⠐⢄⠙⢆⢳⠈⢦⠀⡿⠀⣧⠘⣧⢰⠀⠀⣿⠀⠀⡔⠁⣸⠘⠀⠀⠀⠀⢀⣀⢀⠀⠀⠀⠄⠄⡠⠀",
        "⠀⠀⠀⠀⠀⣷⣿⢿⠋⢀⡤⠀⠀⠀⠀⢢⠈⠸⡆⠈⢆⢳⠀⠙⢧⡁⣾⠀⠀⠘⠀⠌⠀⢀⡟⠀⠀⠀⠀⠀⠹⣿⣿⣶⣦⣀⠀⡼⠁⡔",
        "⠀⠀⠀⣢⣿⣿⣿⠃⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠈⠊⡄⠀⠀⢡⡇⠀⠀⠀⠀⠀⠀⠈⠀⣶⣦⠀⠀⠀⠀⢹⣿⣿⣿⣷⡈⢀⠜⠀",
        "⠀⠀⢠⣾⣿⡿⡏⠰⠁⠀⢀⠄⠀⠀⠀⢠⡾⠀⠀⠀⠀⠀⠈⠀⠀⠈⠀⠀⢀⠀⠀⠀⢠⡀⢀⢹⣿⣧⠘⡆⡆⢸⣿⣿⣿⣿⢃⠔⠊⠀",
        "⠀⠀⠈⣿⣿⡇⢳⢀⠄⣠⠇⠀⠀⣰⢀⣿⠁⠀⠀⣠⡞⢀⠆⣰⠀⠀⢀⠀⣸⠀⣶⢀⣿⣧⠈⣎⣿⣿⠄⠀⣿⢸⢿⣿⣿⣏⠀⠄⠂⠀",
        "⠀⠀⠀⠸⠿⠗⠈⢾⠀⣟⡇⠀⠠⣽⢸⡇⠀⢀⢠⣿⠁⢃⣼⢃⡀⠀⡏⢸⣿⠀⠀⣼⣿⣿⠀⢸⣿⣿⠁⣸⣿⣿⢸⣿⣿⡇⠈⠔⠀⠀",
        "⡅⠀⢠⣥⣷⣶⣿⣿⡔⣿⠇⢀⡄⠸⡘⡇⠀⢀⣾⠛⠀⢘⣵⣿⡀⠘⢀⣿⣿⠀⢠⣿⣿⣿⠀⣸⣿⡏⣠⣿⣿⣿⣷⣾⣿⣷⣶⡄⠀⡇",
        "⢡⠀⣾⣧⡙⠿⣿⣿⣿⣿⡆⢰⣷⣶⣙⠄⣸⣼⣿⡇⢠⣺⣿⣿⡇⠀⢸⣿⠟⠀⢸⡿⣛⡟⢠⣿⣿⣿⣿⣿⣿⣿⡿⠟⣻⣿⣿⣷⢸⠁",
        "⢸⡄⣿⣿⣷⣄⠀⠈⠙⢿⣷⠸⣿⣿⣿⣆⢣⣿⣿⣿⠀⢺⣿⣿⣷⠀⡟⢣⣾⠀⣿⣾⣿⣣⣾⡟⣿⣿⣿⠿⠛⠁⢀⣴⣿⣿⣿⣯⣾⡆",
        "⢰⢻⣿⣿⣿⣿⣷⣦⣀⠀⠈⠑⠙⠿⣿⣿⣧⣿⣿⣿⣿⡎⣿⣿⣿⡆⢧⣾⣿⣇⣾⡿⠿⠛⠁⠀⠁⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⠆",
        "⢠⣹⣿⣿⣿⣿⣿⣎⠻⡿⢶⣤⡄⣀⠀⠀⠀⠀⠙⠻⠟⠁⣟⣿⣿⠀⠼⠛⠟⠋⠁⠀⠀⠀⠀⣀⢀⣠⣠⡤⢀⣾⣿⣿⣿⣿⣿⣿⠂",
        "⠀⢿⣻⣿⣿⣿⣿⣿⣥⣆⢍⢉⣉⣉⣁⠀⠀⠀⠀⢀⡠⠀⠸⢿⣧⢂⠀⠀⠀⠀⠀⠀⠺⠿⠷⠶⢚⡛⠋⣡⣾⣿⣿⣿⣿⣿⣿⣣⡏⠀",
        "⠀⠈⠃⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⣶⣯⣤⣀⣲⠀⠀⢸⣯⣥⣷⣶⣶⣾⣿⣿⣿⣯⣤⣶⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⡏⢛⡤⠀",
        "⠀⠀⣷⢸⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⡶⣄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃⣿⣏⠀",
        "⠀⠀⢹⡎⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡛⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣾⣏⡞⠀",
        "⠀⠀⠸⣷⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡕⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣸⣟⡿⠁⠀",
        "⠀⠀⠀⢿⣆⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡥⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢡⡿⣿⠃⠀⠀",
        "⠀⠀⠀⠀⠳⠥⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⢠⣿⣽⠏⠀⠀⠀",
        "⠀⠈⠀⠀⠐⠒⠶⢠⣌⣉⠉⠉⠉⠛⠽⣻⣿⣿⣿⠇⠻⣿⡿⣿⣿⣿⣿⣿⢟⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠛⠋⠀⠀⠈⢉⠀⣀⣀⣷⡆",
        "⠂⠀⠀⠀⠀⠀⠀⠀⠚⠉⠳⢒⣦⣀⢀⠈⠙⠩⠴⣞⡁⠌⠻⠿⣿⣿⠟⢡⣾⣿⣿⠿⠛⠋⠁⠀⠀⡀⠀⡀⢀⠀⠠⣠⣞⠀⣂⠗⠁⠃",
        "⠠⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠟⠿⠆⡄⠀⠀⠈⠙⠳⠤⠤⠄⠀⠒⠛⠉⠉⠀⠀⣠⣀⣦⣤⣠⣴⣒⡻⢺⠛⠓⠓⠎⠘⠟⠁⠀⠀",
        "⢤⠀⠀⠙⠤⡀⠀⡀⠤⢤⡀⠀⠀⠀⠠⣒⠿⠿⠧⡦⣰⣄⣄⢤⣀⣐⢦⣔⠄⡒⠦⡼⠿⣽⣻⡷⠟⡉⠉⠁⠊⠀⠌⠀⠀⠀⠀⠀⠀⠀",
        "⢤⠐⠀⠘⠀⣉⠀⠀⠰⠈⠹⠀⠀⠀⠁⠀⠈⠀⠀⠒⠓⠉⠟⠋⠘⠁⠈⠐⠉⠁⠉⠐⠉⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Buscar archivo",    ":Telescope find_files<CR>"),
        dashboard.button("r", "  Archivos recientes", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "  Buscar texto",       ":Telescope live_grep<CR>"),
        dashboard.button("e", "  Nuevo archivo",      ":enew<CR>"),
        dashboard.button("q", "  Salir",              ":qa<CR>"),
      }

      dashboard.section.footer.val = ""

      alpha.setup(dashboard.config)
    end
  },

  -- 3. BARRA DE ESTADO
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "monokai-pro",
          icons_enabled = true,
          section_separators = "",
          component_separators = "|",
        }
      })
    end
  },

  -- 4. SINTAXIS INTELIGENTE
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1005,
    config = function()
      local configs = require("nvim-treesitter.config")

      configs.setup({
        -- Se añadieron "go" y "gomod" a Treesitter
        ensure_installed = { "html", "css", "javascript", "typescript", "tsx", "svelte", "lua", "vim", "java", "go", "gomod" },
        auto_install = true,
        modules = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },

  -- 5. BUSCADOR
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    end
  },

  -- 6. EXPLORADOR DE ARCHIVOS
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        enable_git_status = true,
        window = { width = 30 },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
          }
        }
      })
      vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { silent = true })
    end
  },

  -- 7. GIT EN EL MARGEN
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add    = { text = "+" },
          change = { text = "~" },
          delete = { text = "-" },
        }
      })
    end
  },

  -- 8. GESTIÓN AUTOMÁTICA DE INFRAESTRUCTURA LSP
  {
    "williamboman/mason.nvim",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        -- Se añade gopls para el soporte del servidor LSP de Go
        ensure_installed = { "clangd", "ts_ls", "svelte", "jdtls", "gopls" },
      })
    end
  },

  -- 9. SOPORTE AVANZADO DE JAVA (jdtls)
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local function setup_jdtls()
        local jdtls = require("jdtls")
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
        local mason_path = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local extendedClientCapabilities = jdtls.extendedClientCapabilities
        extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

        local function on_attach(client, bufnr)
          local opts = { buffer = bufnr, silent = true }

          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

          vim.keymap.set("n", "<leader>oi", jdtls.organize_imports, opts)
          vim.keymap.set("n", "<leader>ev", jdtls.extract_variable, opts)
          vim.keymap.set("v", "<leader>ev", function() jdtls.extract_variable(true) end, opts)
          vim.keymap.set("n", "<leader>ec", jdtls.extract_constant, opts)
          vim.keymap.set("v", "<leader>ec", function() jdtls.extract_constant(true) end, opts)
          vim.keymap.set("v", "<leader>em", function() jdtls.extract_method(true) end, opts)
        end

        local config = {
          cmd = { mason_path, "-data", workspace_dir },
          root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle", "build.gradle.kts" }),
          capabilities = capabilities,
          on_attach = on_attach,
          settings = {
            java = {
              signatureHelp = { enabled = true },
              completion = { favoriteStaticMembers = {} },
              contentProvider = { preferred = "fernflower" },
            },
          },
          init_options = {
            bundles = {},
            extendedClientCapabilities = extendedClientCapabilities,
          },
        }

        jdtls.start_or_attach(config)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = setup_jdtls,
      })
    end
  },

  -- 10. AUTOCOMPLETADO
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end
  },

  -- Iconos modernos de Mini.icons
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = false,
    config = function()
      local icons = require("mini.icons")
      icons.setup({ style = "glyph" })
      icons.mock_nvim_web_devicons()
    end,
  },
})

-- =============================================================================
-- CONFIGURACIÓN DE SERVIDORES LSP (Nueva API Nativa de Neovim)
-- =============================================================================

local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

-- C / C++ (clangd)
vim.lsp.config('clangd', {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable('clangd')

-- TypeScript / JavaScript / SvelteKit (ts_ls)
vim.lsp.config('ts_ls', {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  capabilities = lsp_capabilities,
})
vim.lsp.enable('ts_ls')

-- Svelte (svelteserver)
vim.lsp.config('svelte', {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
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
  settings = {
    svelte = {
      plugin = {
        svelte = {
          defaultScriptLanguage = "ts",
        },
      },
    },
  },
})
vim.lsp.enable('svelte')

-- Go (gopls)
vim.lsp.config('gopls', {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  capabilities = lsp_capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})
vim.lsp.enable('gopls')

-- =============================================================================
-- INTERFAZ Y MAPEOS DE TERMINAL
-- =============================================================================

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
})

-- Mapeos comunes de LSP para clangd, ts_ls, svelte y gopls
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil or client.name == "jdtls" then
      return
    end
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- Salir del modo terminal
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Salir del modo terminal' })
