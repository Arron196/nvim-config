return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "bash",
        "c",
        "cpp",
        "go",
        "html",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      }

      local ts = require("nvim-treesitter")
      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      ts.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("benja-treesitter", { clear = true }),
        pattern = {
          "bash",
          "c",
          "cpp",
          "go",
          "html",
          "json",
          "lua",
          "markdown",
          "python",
          "query",
          "rust",
          "toml",
          "vim",
          "yaml",
        },
        callback = function(args)
          pcall(vim.treesitter.start)

          local indent_langs = {
            bash = true,
            c = true,
            cpp = true,
            go = true,
            lua = true,
            python = true,
            query = true,
            rust = true,
            vim = true,
          }

          if indent_langs[args.match] then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
