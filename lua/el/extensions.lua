local Job = require "plenary.job"

local modes = require("el.data").modes
local mode_highlights = require("el.data").mode_highlights
local sections = require "el.sections"

local extensions = {}

local git_insertions = vim.regex [[\(\d\+\)\( insertions\)\@=]]
local git_changed = vim.regex [[\(\d\+\)\( file changed\)\@=]]
local git_deletions = vim.regex [[\(\d\+\)\( deletions\)\@=]]

local parse_shortstat_output = function(s)
  local result = {}

  local insert = { git_insertions:match_str(s) }
  if not vim.tbl_isempty(insert) then
    table.insert(result, string.format("+%s", string.sub(s, insert[1] + 1, insert[2])))
  end

  local changed = { git_changed:match_str(s) }
  if not vim.tbl_isempty(changed) then
    table.insert(result, string.format("~%s", string.sub(s, changed[1] + 1, changed[2])))
  end

  local delete = { git_deletions:match_str(s) }
  if not vim.tbl_isempty(delete) then
    table.insert(result, string.format("-%s", string.sub(s, delete[1] + 1, delete[2])))
  end

  if vim.tbl_isempty(result) then
    return nil
  end

  return string.format("[%s]", table.concat(result, ", "))
end

--- @type el.Item
extensions.git_changes = function(_, buffer)
  if
    vim.api.nvim_get_option_value("bufhidden", { buf = buffer.bufnr }) ~= ""
    or vim.api.nvim_get_option_value("buftype", { buf = buffer.bufnr }) == "nofile"
  then
    return
  end

  if vim.fn.filereadable(buffer.fullpath) ~= 1 then
    return
  end

  local j = Job:new {
    command = "git",
    args = { "diff", "--shortstat", buffer.fullpath },
    cwd = vim.fn.fnamemodify(buffer.fullpath, ":h"),
  }

  local ok, result = pcall(function()
    return parse_shortstat_output(vim.trim(j:sync()[1]))
  end)

  if ok then
    return result
  end
end

extensions.git_branch = function(_, buffer)
  local j = Job:new {
    command = "git",
    args = { "branch", "--show-current" },
    cwd = vim.fn.fnamemodify(buffer.fullpath, ":h"),
  }

  local ok, result = pcall(function()
    return vim.trim(j:sync()[1])
  end)

  if ok then
    return result
  end
end

local mode_dispatch = setmetatable({}, {
  __index = function(parent, format_string)
    local dispatcher = setmetatable({}, {
      __index = function(child, k)
        local higroup = mode_highlights[k]
        local inactive_higroup = higroup .. "Inactive"

        local display_name = modes[k][1]
        local contents = string.format(format_string, display_name)
        local highlighter = sections.gen_one_highlight(contents)

        local val = function(window, buffer)
          return highlighter(window, buffer, (window.is_active and higroup) or inactive_higroup)
        end

        rawset(child, k, val)
        return val
      end,
    })

    rawset(parent, format_string, dispatcher)
    return dispatcher
  end,
})

--- @param opts? {format_string: string}
--- @return el.Item
extensions.gen_mode = function(opts)
  opts = opts or {}

  local format_string = opts.format_string or "[%s]"

  return function(window, buffer)
    local mode = vim.api.nvim_get_mode().mode
    return mode_dispatch[format_string][mode](window, buffer)
  end
end

extensions.mode = extensions.gen_mode()

--- @param opts {format_string: string, color_icon: boolean}
--- @return el.Item
extensions.file_icon = function(opts)
  return function(_, buffer)
    opts = opts or {}

    local format_string = opts.format_string or "%s"

    local ok, icon, hi_group = pcall(function()
      return require("nvim-web-devicons").get_icon(buffer.name, buffer.extension, { default = true })
    end)

    if not ok then
      return ""
    end

    vim.api.nvim_set_hl(0, "ElFileIcon", { link = hi_group })

    if not opts.color_icon then
      return format_string:format(icon)
    end

    return sections.highlight({ active = "ElFileIcon" }, format_string:format(icon))(_, buffer)
  end
end

--- @type el.Item
extensions.git_icon = function()
  local ok, icon = pcall(function()
    return require("nvim-web-devicons").get_icon ".gitattributes"
  end)
  return ok and icon or ""
end

return extensions
