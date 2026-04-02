local M = {}

local run_state = {
  buf = nil,
  win = nil,
}

local function open_tutor(locale, tutorial)
  vim.cmd("language messages " .. locale)
  vim.cmd("Tutor " .. tutorial)
end

local function ps_quote(value)
  return "'" .. value:gsub("'", "''") .. "'"
end

local function join_path(...)
  return vim.fs.joinpath(...)
end

local function file_stem(path)
  return vim.fn.fnamemodify(path, ":t:r")
end

local function file_dir(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

local function find_upward(start_dir, marker)
  local matches = vim.fs.find(marker, {
    path = start_dir,
    upward = true,
    stop = vim.fs.dirname(vim.loop.os_homedir()),
  })
  return matches[1]
end

function M.build_run_spec(path, filetype)
  local dir = file_dir(path)
  local cache_dir = join_path(vim.fn.stdpath("cache"), "run")
  vim.fn.mkdir(cache_dir, "p")

  if filetype == "python" then
    return {
      cwd = find_upward(dir, "pyproject.toml") and file_dir(find_upward(dir, "pyproject.toml")) or dir,
      command = "python " .. ps_quote(path),
    }
  end

  if filetype == "go" then
    return {
      cwd = dir,
      command = "go run .",
    }
  end

  if filetype == "rust" then
    local cargo_toml = find_upward(dir, "Cargo.toml")
    if cargo_toml then
      return {
        cwd = file_dir(cargo_toml),
        command = "cargo run",
      }
    end

    local exe = join_path(cache_dir, file_stem(path) .. ".exe")
    return {
      cwd = dir,
      command = "rustc "
        .. ps_quote(path)
        .. " -o "
        .. ps_quote(exe)
        .. "; if ($?) { & "
        .. ps_quote(exe)
        .. " }",
    }
  end

  if filetype == "c" then
    local cc = vim.fn.executable("gcc") == 1 and "gcc" or "clang"
    if vim.fn.executable(cc) ~= 1 then
      return nil
    end

    local exe = join_path(cache_dir, file_stem(path) .. ".exe")
    return {
      cwd = dir,
      command = cc
        .. " "
        .. ps_quote(path)
        .. " -O0 -g -o "
        .. ps_quote(exe)
        .. "; if ($?) { & "
        .. ps_quote(exe)
        .. " }",
    }
  end

  if filetype == "cpp" then
    local cxx = vim.fn.executable("g++") == 1 and "g++" or "clang++"
    if vim.fn.executable(cxx) ~= 1 then
      return nil
    end

    local exe = join_path(cache_dir, file_stem(path) .. ".exe")
    return {
      cwd = dir,
      command = cxx
        .. " "
        .. ps_quote(path)
        .. " -std=c++20 -O0 -g -o "
        .. ps_quote(exe)
        .. "; if ($?) { & "
        .. ps_quote(exe)
        .. " }",
    }
  end

  if filetype == "lua" then
    return {
      cwd = dir,
      command = "lua " .. ps_quote(path),
    }
  end

  return nil
end

local function open_run_terminal(spec)
  if run_state.win and vim.api.nvim_win_is_valid(run_state.win) then
    pcall(vim.api.nvim_win_close, run_state.win, true)
  end
  if run_state.buf and vim.api.nvim_buf_is_valid(run_state.buf) then
    pcall(vim.api.nvim_buf_delete, run_state.buf, { force = true })
  end

  vim.cmd("botright 12split")
  vim.cmd("enew")

  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  run_state.buf = buf
  run_state.win = win

  vim.bo[buf].buflisted = false
  vim.bo[buf].bufhidden = "wipe"

  vim.fn.termopen({
    "pwsh",
    "-NoLogo",
    "-NoExit",
    "-Command",
    spec.command,
  }, {
    cwd = spec.cwd,
  })

  vim.cmd("startinsert")
end

function M.run_current_file()
  local path = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype

  if path == "" then
    vim.notify("Current buffer has no file path.", vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    vim.cmd.write()
  end

  local spec = M.build_run_spec(path, filetype)
  if not spec then
    vim.notify("No run command configured for filetype: " .. filetype, vim.log.levels.WARN)
    return
  end

  open_run_terminal(spec)
end

vim.api.nvim_create_user_command("TutorZh", function()
  open_tutor("zh_CN.UTF-8", "vim-01-beginner")
end, {
  desc = "Open Chinese tutor lesson 1",
})

vim.api.nvim_create_user_command("TutorZh2", function()
  open_tutor("zh_CN.UTF-8", "vim-02-beginner")
end, {
  desc = "Open Chinese tutor lesson 2",
})

vim.api.nvim_create_user_command("RunCurrentFile", function()
  M.run_current_file()
end, {
  desc = "Run current file in terminal split",
})

return M
