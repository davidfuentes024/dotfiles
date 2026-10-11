return {
  -- BUSCADOR
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

      window = {
        width = 30,

        mappings = {
          ["P"] = "play_audio",
        },
      },

      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
      },

      commands = {
        play_audio = function(state)
          local node = state.tree:get_node()

          if not node or not node.path then
            return
          end

          local path = node.path

          if not path:match("%.wav$") then
            vim.notify(
              "Selecciona un archivo .wav",
              vim.log.levels.WARN
            )
            return
          end

          vim.fn.jobstart({
            "mpv",
            "--no-video",
            "--really-quiet",
            path,
          }, {
            detach = true,
          })

          vim.notify("▶ " .. vim.fn.fnamemodify(path, ":t"))
        end,
      },
    })

    vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", {
      silent = true,
    })
  end,
},

  -- SINTAXIS
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1005,
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "html", "css", "javascript", "typescript", "tsx", "svelte", "lua", "vim", "java", "go", "gomod", "gowork", "gotmpl" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- GIT
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = { add = { text = "+" }, change = { text = "~" }, delete = { text = "-" } }
      })
    end
  },

  -- REVISAR CAMBIOS DE CLAUDE CODE (por prompt, no por commit)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup({})

      local function open_claude_diff()
        local git_dir = vim.fn.systemlist("git rev-parse --git-dir")[1]
        if vim.v.shell_error ~= 0 or not git_dir then
          vim.notify("No estás dentro de un repo git", vim.log.levels.WARN)
          return
        end

        local marker = git_dir .. "/CLAUDE_LAST_REVIEW_BASE"
        local f = io.open(marker, "r")
        if not f then
          vim.notify("Todavía no hay cambios de Claude Code para revisar", vim.log.levels.WARN)
          return
        end

        local base_sha = f:read("*l")
        f:close()

        if not base_sha or base_sha == "" then
          vim.notify("Marcador de Claude Code vacío", vim.log.levels.WARN)
          return
        end

        vim.cmd("DiffviewOpen " .. base_sha)
      end

      vim.api.nvim_create_user_command("ClaudeDiff", open_claude_diff, {})
      vim.keymap.set("n", "<leader>cd", open_claude_diff, { desc = "Ver cambios del último prompt de Claude Code" })
    end
  },

  -- MARKDOWN
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
}
