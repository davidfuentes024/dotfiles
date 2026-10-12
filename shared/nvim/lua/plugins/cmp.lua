return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")

      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      -- Code completion only: no suggestions while writing prose or comments
      local prose_filetypes = { markdown = true, text = true, gitcommit = true }
      local context = require("cmp.config.context")

      -- Looks at the syntax tree under the cursor (the character just typed),
      -- which works even where highlight captures are not available
      local function in_comment()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, math.max(col - 1, 0) } })
        while ok and node do
          if node:type():find("comment") then return true end
          node = node:parent()
        end
        return context.in_syntax_group("Comment")
      end

      cmp.setup({
        enabled = function()
          if vim.bo.buftype == "prompt" or prose_filetypes[vim.bo.filetype] then
            return false
          end
          return not in_comment()
        end,
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        -- No "buffer" source: it suggested plain words from the file while typing
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "path" } }
        ),
      })
    end
  }
}
