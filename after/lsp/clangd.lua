local cmd = {
  "clangd",
  "--background-index",
  "--clang-tidy",
  "--header-insertion=iwyu",
}

local gxx = vim.fn.exepath("g++")
if gxx ~= "" then
  table.insert(cmd, "--query-driver=" .. gxx)
end

local gcc = vim.fn.exepath("gcc")
if gcc ~= "" then
  table.insert(cmd, "--query-driver=" .. gcc)
end

return {
  cmd = cmd,
  init_options = {
    clangdFileStatus = true,
  },
}
