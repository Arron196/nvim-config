return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "ruff",
        "gopls",
        "clangd",
        "rust_analyzer",
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "Saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "super-tab",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "select_and_accept", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        ghost_text = {
          enabled = false,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
          },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
      },
      signature = {
        enabled = true,
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            score_offset = 4,
          },
        },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "Saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
        underline = true,
        signs = true,
        virtual_text = {
          source = "if_many",
          spacing = 2,
          prefix = "●",
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("benja-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            vim.keymap.set(mode or "n", keys, func, {
              buffer = event.buf,
              desc = "LSP: " .. desc,
            })
          end

          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gi", vim.lsp.buf.implementation, "Goto implementation")
          map("gr", vim.lsp.buf.references, "Goto references")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({
            async = true,
            lsp_format = "fallback",
          })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function()
        return {
          timeout_ms = 3000,
          lsp_format = "fallback",
        }
      end,
      formatters = {
        clang_format = {
          prepend_args = { "--style=Microsoft" },
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        ["*"] = { "trim_whitespace" },
      },
    },
  },
}
