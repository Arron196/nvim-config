return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 200,
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>e", desc = "explorer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "leetcode" },
        { "<leader>r", group = "run" },
        { "<leader>s", group = "split" },
        { "<leader>u", group = "ui" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        component_separators = "|",
        section_separators = "",
        globalstatus = true,
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        char = "|",
      },
      scope = {
        enabled = false,
      },
    },
  },
}
