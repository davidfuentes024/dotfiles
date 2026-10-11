return {
  -- TEMA: One Dark Pro (Negro puro y limpio)
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    config = function()
      require("onedarkpro").setup({
        options = {
          transparency = true, -- Fondo transparente real
          highlight_inactive_windows = false,
        },
      })
      vim.cmd.colorscheme("onedark")
    end
  },

  -- BARRA DE ESTADO (Sincronizada con One Dark)
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "onedark",
          icons_enabled = true,
          section_separators = "",
          component_separators = "|",
        }
      })
    end
  },

  -- ICONOS
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

  -- DASHBOARD
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
        "⠀⠀⠀⠀⠀⣷⣿⢿⠋⢀⡤⠀⠀⠀⠀⢢⠈⠸⡆⠈⢆⢳⠀⠙⢧⡁⣾⠀⠀⠘⠀⠌⠀ ⡟⠀⠀⠀⠀⠀⠹⣿⣿⣶⣦⣀⠀⡼⠁⡔",
        "⠀⠀⠀⣢⣿⣿⣿⠃⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠈⠊⡄⠀⠀⢡⡇⠀⠀⠀⠀⠀⠀⠈⠀⣶⣦⠀⠀⠀⠀⢹⣿⣿⣿⣷⡈⢀⠜⠀",
        "⠀⠀⢠⣾⣿⡿⡏⠰⠁⠀⢀⠄⠀⠀⠀⢠⡾⠀⠀⠀⠀⠀⠈⠀⠀⠈⠀⠀⢀⠀⠀⠀⢠⡀⢀⢹⣿⣧⠘⡆⡆⢸⣿⣿⣿⣿⢃⠔⠊⠀",
        "⠀⠀⠈⣿⣿⡇⢳⢀⠄⣠⠇⠀⠀⣰⢀⣿⠁⠀⠀⣠⡞⢀⠆⣰⠀⠀⢀⠀⣸⠀⣶⢀⣿⣧⠈⣎⣿⣿⠄⠀⣿⢸⢿⣿⣿⣏⠀⠄⠂⠀",
        "⠀⠀⠀⠸⠿⠗⠈⢾⠀⣟⡇⠀⠠⣽⢸⡇⠀⢀⢠⣿⠁⢃⣼⢃⡀⠀⡏⢸⣿⠀⠀⣼⣿⣿⠀⢸⣿⣿⠁⣸⣿⣿⢸⣿⣿⡇⠈⠔⠀⠀",
        "⡅⠀⢠⣥⣷⣶⣿⣿⡔⣿⠇⢀⡄⠸⡘⡇⠀⢀⣾⠛⠀⢘⣵⣿⡀⠘⢀⣿⣿⠀⢠⣿⣿⣿⠀⣸⣿⡏⣠⣿⣿⣿⣷⣾⣿⣷⣶⡄⠀⡇",
        "⢡⠀⣾⣧⡙⠿⣿⣿⣿⣿⡆⢰⣷⣶⣙⠄⣸⣼⣿⡇⢠⣺⣿⣿⡇⠀⢸⣿⠟⠀⢸⡿⣛⡟⢠⣿⣿⣿⣿⣿⣿⣿⡿⠟⣻⣿⣿⣷⢸⠁",
        "⢸⡄⣿⣿⣷⣄⠀⠈⠙⢿⣷⠸⣿⣿⣿⣆⢣⣿⣿⣿⠀⢺⣿⣿⡷⠀⡟⢣⣾⠀⣿⣾⣿⣣⣾⡟⣿⣿⣿⠿⠛⠁⢀⣴⣿⣿⣿⣯⣾⡆",
        "⢰⢻⣿⣿⣿⣿⣷⣦⣀⠀⠈⠑⠙⠿⣿⣿⣧⣿⣿⣿⣿⡎⣿⣿⣿⡆⢧⣾⣿⣇⣾⡿⠿⠛⠁⠀⠁⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⠆",
        "⢠⣹⣿⣿⣿⣿⣿⣎⠻⡿⢶⣤⡄⣀⠀⠀⠀⠀⠙⠻⠟⠁⣟⣿⣿⠀⠼⠛⠟⠋⠁⠀⠀⠀⠀⣀⢀⣠⣠⡤⢀⣾⣿⣿⣿⣿⣿⣿⠂",
        "⠀⢿⣻⣿⣿⣿⣿⣿⣥⣆⢍⢉⣉⣉⣁⠀⠀⠀⠀⢀⡠⠀⠸⢿⣧⢂⠀⠀⠀⠀⠀⠀⠺⠿⠷⠶⢚⡛⠋⣡⣾⣿⣿⣿⣿⣿⣿⣣⡏⠀",
        "⠀⠈⠃⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⣶⣯⣤⣀⣲⠀⠀⢸⣯⣥⣷⣶⣶⣾⣿⣿⣿⣯⣤⣶⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⡏⢛⡤⠀",
        "⠀⠀⣷⢸⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⡶⣄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃⣿⣏⠀",
        "⠀⠀⢹⡎⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡛⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣾⣏⡞⠀",
        "⠀⠀⠸⣷⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡕⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣸⣟⡿⠁⠀",
        "⠀⠀⠀⢿⣆⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡥⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢡⡿⣿⠃⠀⠀",
        "⠀⠀⠀⠀⠳⠥⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⢠⣿⣽⠏⠀⠀⠀",
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
  }
}
