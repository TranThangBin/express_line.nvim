-- General Idea:
--
-- Buffer
--  Wrapper around common buffer operations
--  Should make it super speedy fast, and not have to re-evaluate all the time
--
--  For example,
--
--      local buffer = Buffer:new(bufnr)
--      buffer.bufnr == bufnr
--      if buffer.filetype == 'lua' then print("Yo, it's lua") end
--
--  The thing is, `filetype` gets looked up only once and we pass the buffer object around to the calls.
--

-- Other TODO:
--  Should be possible to attach your own "lookups" to buffer,
--      so that you can get the same (sometimes expensive) behavior.
--
--      For example, whether this buffer contains a file in a git directory.
--          buffer.is_git => function(buffer) return can_find_dot_git(buffer.path) end

local meta = {}

--- @class el.Buffer
--- @field bufnr integer
--- @field filetype string
--- @field fullpath string
--- @field name string
--- @field extension string
--- @field is_git boolean
--- @field lsp boolean
--- @field is_active boolean

local buf_lookups = {
  filetype = function(buffer)
    return vim.api.nvim_get_option_value("filetype", { bufnr = buffer.bufnr })
  end,

  fullpath = function(buffer)
    return vim.api.nvim_buf_get_name(buffer.bufnr)
  end,

  name = function(buffer)
    return vim.fn.fnamemodify(buffer.fullpath, ":t")
  end,

  extension = function(buffer)
    return vim.fn.fnamemodify(buffer.fullpath, ":e")
  end,

  -- NOTE: snooze the unused local
  --- @diagnostic disable-next-line
  is_git = function(buffer) end,

  lsp = function(buffer)
    return not vim.tbl_isempty(vim.tbl_keys(vim.lsp.get_clients { bufnr = buffer.bufnr }))
  end,

  is_active = function(buffer)
    return buffer.bufnr == vim.api.nvim_get_current_buf()
  end,
}

local Buffer = {}

local buf_mt = {
  __index = function(t, k)
    local result = nil

    if Buffer[k] ~= nil then
      result = Buffer[k]
    elseif buf_lookups[k] ~= nil then
      result = buf_lookups[k](t)
    end

    t[k] = result
    return t[k]
  end,
}

--- @param bufnr integer
--- @return el.Buffer
function Buffer:new(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  return setmetatable({
    bufnr = bufnr,
  }, buf_mt)
end

meta.Buffer = Buffer

meta.Window = {}

--- @class el.Window
--- @field win_id integer
--- @field width integer, boolean
--- @field height integer, boolean
--- @field is_active boolean, boolean

local win_looksup = {
  width = function(window)
    return vim.api.nvim_win_get_width(window.win_id), false
  end,

  height = function(window)
    return vim.api.nvim_win_get_height(window.win_id), false
  end,

  is_active = function(window)
    return window.win_id == vim.api.nvim_get_current_win(), false
  end,
}

local window_mt = {
  __index = function(t, k)
    local result, should_save = nil, nil

    if meta.Window[k] ~= nil then
      result = meta.Window[k]
    elseif win_looksup[k] ~= nil then
      result, should_save = win_looksup[k](t)
    end

    if should_save ~= false then
      t[k] = result
    end

    return result
  end,
}

--- @param win_id integer
--- @return el.Window
function meta.Window:new(win_id)
  return setmetatable({
    win_id = win_id,
  }, window_mt)
end

return meta
