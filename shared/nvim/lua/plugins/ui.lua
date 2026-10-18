return {
  -- STATUS LINE (follows the colors set in lua/core/theme.lua)
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = true,
          section_separators = "",
          component_separators = "|",
        }
      })
    end
  },

  -- ICONS
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
