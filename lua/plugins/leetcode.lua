local leet_arg = "leetcode.nvim"
local function ensure_leetcode_cpp_support()
  local home = vim.fn.stdpath("data") .. "/leetcode"
  vim.fn.mkdir(home, "p")

  local header = vim.fs.joinpath(home, "leetcode.hpp")
  local clangd = vim.fs.joinpath(home, ".clangd")

  local header_content = table.concat({
    "#pragma once",
    "",
    "#include <algorithm>",
    "#include <array>",
    "#include <bitset>",
    "#include <cmath>",
    "#include <deque>",
    "#include <functional>",
    "#include <iostream>",
    "#include <limits>",
    "#include <list>",
    "#include <map>",
    "#include <numeric>",
    "#include <queue>",
    "#include <set>",
    "#include <sstream>",
    "#include <stack>",
    "#include <string>",
    "#include <tuple>",
    "#include <unordered_map>",
    "#include <unordered_set>",
    "#include <utility>",
    "#include <vector>",
    "",
    "using namespace std;",
  }, "\n")

  local clangd_content = table.concat({
    "CompileFlags:",
    "  Add:",
    "    - -std=c++20",
    "    - -include",
    "    - leetcode.hpp",
  }, "\n")

  if vim.fn.filereadable(header) == 0 or table.concat(vim.fn.readfile(header), "\n") ~= header_content then
    vim.fn.writefile(vim.split(header_content, "\n"), header)
  end

  if vim.fn.filereadable(clangd) == 0 or table.concat(vim.fn.readfile(clangd), "\n") ~= clangd_content then
    vim.fn.writefile(vim.split(clangd_content, "\n"), clangd)
  end
end

return {
  {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>ll",
        "<cmd>Leet list<CR>",
        desc = "LeetCode list",
      },
      {
        "<leader>ld",
        "<cmd>Leet daily<CR>",
        desc = "LeetCode daily",
      },
      {
        "<leader>lr",
        "<cmd>Leet random<CR>",
        desc = "LeetCode random",
      },
      {
        "<leader>lt",
        "<cmd>Leet test<CR>",
        desc = "LeetCode test",
      },
      {
        "<leader>ls",
        "<cmd>Leet submit<CR>",
        desc = "LeetCode submit",
      },
      {
        "<leader>lb",
        "<cmd>Leet tabs<CR>",
        desc = "LeetCode tabs",
      },
      {
        "<leader>li",
        "<cmd>Leet info<CR>",
        desc = "LeetCode info",
      },
      {
        "<leader>lc",
        "<cmd>Leet cookie update<CR>",
        desc = "LeetCode update cookie",
      },
      {
        "<leader>lg",
        "<cmd>Leet lang<CR>",
        desc = "LeetCode language",
      },
    },
    opts = {
      arg = leet_arg,
      lang = "cpp",
      cn = {
        enabled = true,
        translator = true,
        translate_problems = true,
      },
      injector = {
        ["cpp"] = {
          imports = function()
            return {
              "#include <algorithm>",
              "#include <array>",
              "#include <bitset>",
              "#include <cmath>",
              "#include <deque>",
              "#include <functional>",
              "#include <limits>",
              "#include <list>",
              "#include <map>",
              "#include <numeric>",
              "#include <queue>",
              "#include <set>",
              "#include <stack>",
              "#include <string>",
              "#include <tuple>",
              "#include <unordered_map>",
              "#include <unordered_set>",
              "#include <utility>",
              "#include <vector>",
              "using namespace std;",
            }
          end,
        },
      },
      plugins = {
        non_standalone = true,
      },
      picker = {
        provider = "telescope",
      },
      hooks = {
        enter = {
          ensure_leetcode_cpp_support,
        },
      },
      image_support = false,
    },
  },
}
