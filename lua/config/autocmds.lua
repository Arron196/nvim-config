local group = vim.api.nvim_create_augroup("benja-core", { clear = true })

local tutor_find_state = nil

local tutor_punctuation = {
  ["，"] = true,
  ["。"] = true,
  ["！"] = true,
  ["？"] = true,
  ["："] = true,
  ["；"] = true,
  ["（"] = true,
  ["）"] = true,
  ["【"] = true,
  ["】"] = true,
  ["《"] = true,
  ["》"] = true,
  ["〈"] = true,
  ["〉"] = true,
  ["“"] = true,
  ["”"] = true,
  ["‘"] = true,
  ["’"] = true,
  ["、"] = true,
  ["…"] = true,
  ["—"] = true,
}

local function tutor_projection()
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local text = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1] or ""
  local chars = {}
  local mapping = {}
  local last_conceal_id = nil
  local char_count = vim.fn.strchars(text)

  for i = 0, char_count - 1 do
    local bytecol = vim.fn.byteidx(text, i) + 1
    local char = vim.fn.strcharpart(text, i, 1)
    local conceal_info = vim.fn.synconcealed(line_nr, bytecol)
    local concealed = conceal_info[1]
    local replacement = conceal_info[2]
    local conceal_id = conceal_info[3]

    if concealed == 1 then
      if replacement ~= "" and conceal_id ~= last_conceal_id then
        table.insert(chars, replacement)
        table.insert(mapping, bytecol)
      end
      last_conceal_id = conceal_id
    else
      last_conceal_id = nil
      table.insert(chars, char)
      table.insert(mapping, bytecol)
    end
  end

  return line_nr, chars, mapping
end

local function tutor_visible_index(mapping)
  if #mapping == 0 then
    return 0
  end

  local actual_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local index = 1

  for i, bytecol in ipairs(mapping) do
    if bytecol >= actual_col then
      return i
    end
    index = i
  end

  return index
end

local function tutor_set_visible_index(line_nr, mapping, index)
  if #mapping == 0 then
    return
  end

  index = math.max(1, math.min(index, #mapping))
  vim.api.nvim_win_set_cursor(0, { line_nr, mapping[index] - 1 })
end

local function tutor_char_kind(char, big_word)
  if not char or char == "" then
    return "space"
  end

  if char:match("%s") then
    return "space"
  end

  if big_word then
    return "word"
  end

  if tutor_punctuation[char] or char:match("[%p]") then
    return "punct"
  end

  return "word"
end

local function tutor_first_nonblank(chars)
  local index = 1
  while index <= #chars and chars[index]:match("%s") do
    index = index + 1
  end
  return math.min(index, math.max(#chars, 1))
end

local function tutor_next_start(chars, index, big_word)
  if index >= #chars then
    return #chars
  end

  local i = index
  if tutor_char_kind(chars[i], big_word) == "space" then
    while i <= #chars and tutor_char_kind(chars[i], big_word) == "space" do
      i = i + 1
    end
    return math.min(i, #chars)
  end

  local current_kind = tutor_char_kind(chars[i], big_word)
  while i <= #chars and tutor_char_kind(chars[i], big_word) == current_kind do
    i = i + 1
  end
  while i <= #chars and tutor_char_kind(chars[i], big_word) == "space" do
    i = i + 1
  end

  return math.min(i, #chars)
end

local function tutor_prev_start(chars, index, big_word)
  if index <= 1 then
    return 1
  end

  local i = index
  local current_kind = tutor_char_kind(chars[i], big_word)
  if current_kind ~= "space" and tutor_char_kind(chars[i - 1], big_word) ~= current_kind then
    i = i - 1
  end

  while i > 1 and tutor_char_kind(chars[i], big_word) == "space" do
    i = i - 1
  end
  while i > 1
    and tutor_char_kind(chars[i - 1], big_word) == tutor_char_kind(chars[i], big_word)
    and tutor_char_kind(chars[i], big_word) ~= "space"
  do
    i = i - 1
  end

  return i
end

local function tutor_next_end(chars, index, big_word)
  local i = index
  while i <= #chars and tutor_char_kind(chars[i], big_word) == "space" do
    i = i + 1
  end

  i = math.min(i, #chars)
  local current_kind = tutor_char_kind(chars[i], big_word)
  while i < #chars and tutor_char_kind(chars[i + 1], big_word) == current_kind do
    i = i + 1
  end

  return i
end

local function tutor_prev_end(chars, index, big_word)
  local i = index
  if i > 1 then
    i = i - 1
  end
  while i > 1 and tutor_char_kind(chars[i], big_word) == "space" do
    i = i - 1
  end
  return i
end

local function tutor_apply_step(step_fn, big_word)
  local line_nr, chars, mapping = tutor_projection()
  if #mapping == 0 then
    return
  end

  local index = tutor_visible_index(mapping)
  for _ = 1, vim.v.count1 do
    index = step_fn(chars, index, big_word)
  end

  tutor_set_visible_index(line_nr, mapping, index)
end

local function tutor_visible_find(direction, till, repeat_reverse)
  local line_nr, chars, mapping = tutor_projection()
  if #mapping == 0 then
    return
  end

  local state = tutor_find_state
  if direction ~= nil then
    state = {
      char = vim.fn.getcharstr(),
      direction = direction,
      till = till,
    }
    tutor_find_state = state
  elseif not state then
    return
  end

  local search_direction = state.direction
  if repeat_reverse then
    search_direction = search_direction == "forward" and "backward" or "forward"
  end

  local step = search_direction == "forward" and 1 or -1
  local index = tutor_visible_index(mapping)

  for _ = 1, vim.v.count1 do
    local i = index + step
    local found = nil

    while i >= 1 and i <= #chars do
      if chars[i] == state.char then
        found = i
        break
      end
      i = i + step
    end

    if not found then
      break
    end

    if state.till then
      index = found - step
    else
      index = found
    end
    index = math.max(1, math.min(index, #chars))
  end

  tutor_set_visible_index(line_nr, mapping, index)
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "tutor",
  callback = function()
    vim.keymap.set("n", "h", function()
      tutor_apply_step(function(_, index)
        return math.max(1, index - 1)
      end)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor left by visible char",
    })

    vim.keymap.set("n", "l", function()
      tutor_apply_step(function(chars, index)
        return math.min(#chars, index + 1)
      end)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor right by visible char",
    })

    vim.keymap.set("n", "0", function()
      tutor_apply_step(function()
        return 1
      end)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor line start",
    })

    vim.keymap.set("n", "^", function()
      tutor_apply_step(function(chars)
        return tutor_first_nonblank(chars)
      end)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor first nonblank",
    })

    vim.keymap.set("n", "$", function()
      tutor_apply_step(function(chars)
        return #chars
      end)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor line end",
    })

    vim.keymap.set("n", "w", function()
      tutor_apply_step(tutor_next_start, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor next word",
    })

    vim.keymap.set("n", "W", function()
      tutor_apply_step(tutor_next_start, true)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor next WORD",
    })

    vim.keymap.set("n", "b", function()
      tutor_apply_step(tutor_prev_start, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor previous word",
    })

    vim.keymap.set("n", "B", function()
      tutor_apply_step(tutor_prev_start, true)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor previous WORD",
    })

    vim.keymap.set("n", "e", function()
      tutor_apply_step(tutor_next_end, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor word end",
    })

    vim.keymap.set("n", "E", function()
      tutor_apply_step(tutor_next_end, true)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor WORD end",
    })

    vim.keymap.set("n", "ge", function()
      tutor_apply_step(tutor_prev_end, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor previous word end",
    })

    vim.keymap.set("n", "gE", function()
      tutor_apply_step(tutor_prev_end, true)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor previous WORD end",
    })

    vim.keymap.set("n", "f", function()
      tutor_visible_find("forward", false, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor find char forward",
    })

    vim.keymap.set("n", "F", function()
      tutor_visible_find("backward", false, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor find char backward",
    })

    vim.keymap.set("n", "t", function()
      tutor_visible_find("forward", true, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor till char forward",
    })

    vim.keymap.set("n", "T", function()
      tutor_visible_find("backward", true, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor till char backward",
    })

    vim.keymap.set("n", ";", function()
      tutor_visible_find(nil, nil, false)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor repeat find forward",
    })

    vim.keymap.set("n", ",", function()
      tutor_visible_find(nil, nil, true)
    end, {
      buffer = true,
      silent = true,
      desc = "Tutor repeat find backward",
    })
  end,
})
