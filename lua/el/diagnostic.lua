-- vim.diagnostic wrappers for el

---@tag el.diagnostic
---@config { module = 'el.diagnostic' }

--- @alias el.DiagnosticCounts {errors: number, warnings: number, infos: number, hints: number}
--- @alias el.DiagnosticFormatter fun(win, buf, counts: el.DiagnosticCounts): string?

local severity = vim.diagnostic.severity

local subscribe = require "el.subscribe"

local diagnostic = {}

local get_counts = function(diags)
  local errors, warnings, infos, hints = 0, 0, 0, 0
  for _, d in ipairs(diags) do
    if d.severity == severity.ERROR then
      errors = errors + 1
    elseif d.severity == severity.WARN then
      warnings = warnings + 1
    elseif d.severity == severity.INFO then
      infos = infos + 1
    else
      hints = hints + 1
    end
  end

  return {
    errors = errors,
    warnings = warnings,
    infos = infos,
    hints = hints,
  }
end

local get_buffer_counts = function(_, buffer)
  return get_counts(vim.diagnostic.get(buffer.bufnr))
end

--- @type el.DiagnosticFormatter
local default_diagnostic_formatter = function(_, _, counts)
  local items = {}

  local sign_texts = vim.diagnostic.config().signs.text or { "E", "W", "I", "H" }

  local format_string = "%s:%s"

  if counts.errors > 0 then
    table.insert(items, string.format(format_string, sign_texts[severity.ERROR], counts.errors))
  end

  if counts.warnings > 0 then
    table.insert(items, string.format(format_string, sign_texts[severity.WARN], counts.warnings))
  end

  if counts.infos > 0 then
    table.insert(items, string.format(format_string, sign_texts[severity.INFO], counts.infos))
  end

  if counts.hints > 0 then
    table.insert(items, string.format(format_string, sign_texts[severity.INFO], counts.hints))
  end

  return table.concat(items, " ")
end

--- An item generator, used to create an item that shows diagnostic information
--- for the current buffer
---@param formatter? el.DiagnosticFormatter
diagnostic.make_buffer = function(formatter)
  formatter = formatter or default_diagnostic_formatter

  return subscribe.buf_autocmd("el_buf_diagnostic", "DiagnosticChanged", function(window, buffer)
    return formatter(window, buffer, get_buffer_counts(window, buffer))
  end)
end

return diagnostic
