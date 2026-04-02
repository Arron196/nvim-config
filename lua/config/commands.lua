local M = {}

local run_state = {
  buf = nil,
  win = nil,
}

local uv = vim.uv or vim.loop

local function open_tutor(locale, tutorial)
  vim.cmd("language messages " .. locale)
  vim.cmd("Tutor " .. tutorial)
end

local function ps_quote(value)
  return "'" .. value:gsub("'", "''") .. "'"
end

local function system_name()
  return uv.os_uname().sysname
end

local function is_windows()
  return system_name() == "Windows_NT"
end

local function shell_quote(value)
  if is_windows() then
    return ps_quote(value)
  end
  return vim.fn.shellescape(value)
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

local function pick_executable(candidates)
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

local function executable_suffix()
  if is_windows() then
    return ".exe"
  end
  return ""
end

local function shell_runner()
  if is_windows() then
    local shell = pick_executable({ "pwsh", "powershell" })
    if not shell then
      return nil
    end

    local args = { shell }
    if shell == "pwsh" then
      table.insert(args, "-NoLogo")
    end
    table.insert(args, "-Command")
    return args
  end

  local shell = vim.env.SHELL
  if not shell or shell == "" then
    shell = vim.o.shell
  end
  if not shell or shell == "" then
    shell = "/bin/sh"
  end

  return { shell, "-lc" }
end

local function shell_command(command)
  local runner = shell_runner()
  if not runner then
    return nil
  end

  local cmd = vim.deepcopy(runner)
  table.insert(cmd, command)
  return cmd
end

local function compile_and_run_command(compile_cmd, exe)
  local run_cmd = is_windows() and ("& " .. ps_quote(exe)) or shell_quote(exe)

  if is_windows() then
    return compile_cmd .. "; if ($?) { " .. run_cmd .. " }"
  end

  return compile_cmd .. " && " .. run_cmd
end

function M.build_run_spec(path, filetype)
  local dir = file_dir(path)
  local cache_dir = join_path(vim.fn.stdpath("cache"), "run")
  vim.fn.mkdir(cache_dir, "p")

  if filetype == "python" then
    local python = pick_executable({ "python3", "python" })
    if not python then
      return nil
    end

    local pyproject = find_upward(dir, "pyproject.toml")
    return {
      cwd = pyproject and file_dir(pyproject) or dir,
      cmd = { python, path },
    }
  end

  if filetype == "go" then
    if vim.fn.executable("go") ~= 1 then
      return nil
    end

    return {
      cwd = dir,
      cmd = { "go", "run", "." },
    }
  end

  if filetype == "rust" then
    local cargo_toml = find_upward(dir, "Cargo.toml")
    if cargo_toml and vim.fn.executable("cargo") == 1 then
      return {
        cwd = file_dir(cargo_toml),
        cmd = { "cargo", "run" },
      }
    end

    if vim.fn.executable("rustc") ~= 1 then
      return nil
    end

    local exe = join_path(cache_dir, file_stem(path) .. executable_suffix())
    local command = shell_command(
      compile_and_run_command(
        "rustc " .. shell_quote(path) .. " -o " .. shell_quote(exe),
        exe
      )
    )
    if not command then
      return nil
    end

    return {
      cwd = dir,
      cmd = command,
    }
  end

  if filetype == "c" then
    local cc = vim.fn.executable("gcc") == 1 and "gcc" or "clang"
    if vim.fn.executable(cc) ~= 1 then
      return nil
    end

    local exe = join_path(cache_dir, file_stem(path) .. executable_suffix())
    local command = shell_command(
      compile_and_run_command(
        cc .. " " .. shell_quote(path) .. " -O0 -g -o " .. shell_quote(exe),
        exe
      )
    )
    if not command then
      return nil
    end

    return {
      cwd = dir,
      cmd = command,
    }
  end

  if filetype == "cpp" then
    local cxx = vim.fn.executable("g++") == 1 and "g++" or "clang++"
    if vim.fn.executable(cxx) ~= 1 then
      return nil
    end

    local exe = join_path(cache_dir, file_stem(path) .. executable_suffix())
    local command = shell_command(
      compile_and_run_command(
        cxx .. " " .. shell_quote(path) .. " -std=c++20 -O0 -g -o " .. shell_quote(exe),
        exe
      )
    )
    if not command then
      return nil
    end

    return {
      cwd = dir,
      cmd = command,
    }
  end

  if filetype == "lua" then
    local lua = pick_executable({ "lua", "luajit" })
    if not lua then
      return nil
    end

    return {
      cwd = dir,
      cmd = { lua, path },
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

  vim.fn.termopen(spec.cmd, {
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
