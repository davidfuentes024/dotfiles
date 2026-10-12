return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        -- Mapeo de formateadores por lenguaje
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          svelte = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          markdown = { "prettier" },
          go = { "goimports", "gofumpt" },
          -- Para Java, usará el LSP (jdtls) automáticamente gracias al fallback
        },
        -- Ejecutar al guardar
        format_on_save = {
          -- Si no hay un formateador específico, usa el del LSP (útil para C++ y Java)
          lsp_fallback = true,
          timeout_ms = 1000,
        },
      })
    end,
  }
}
