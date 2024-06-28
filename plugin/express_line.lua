--- @param hi_group string
--- @param link string
local function highlight_group_link(hi_group, link)
  vim.api.nvim_set_hl(0, hi_group, { link = link })
end

local group = vim.api.nvim_create_augroup("ExpressLineHighlightGroup", {})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  pattern = "*",
  callback = function()
    highlight_group_link("ElCommand", "Constant")
    highlight_group_link("ElCommandCV", "Statusline")
    highlight_group_link("ElCommandEx", "Statusline")
    highlight_group_link("ElConfirm", "Statusline")
    highlight_group_link("ElInsertCompletion", "Statusline")
    highlight_group_link("ElInsert", "MsgSeparator")
    highlight_group_link("ElMore", "Statusline")
    highlight_group_link("ElNormal", "Function")
    highlight_group_link("ElNormalOperatorPending", "Statusline")
    highlight_group_link("ElPrompt", "Statusline")
    highlight_group_link("ElReplace", "Statusline")
    highlight_group_link("ElSBlock", "Statusline")
    highlight_group_link("ElSelect", "Statusline")
    highlight_group_link("ElShell", "Statusline")
    highlight_group_link("ElSLine", "Statusline")
    highlight_group_link("ElTerm", "Statusline")
    highlight_group_link("ElVirtualReplace", "Statusline")
    highlight_group_link("ElVisualBlock", "Statusline")
    highlight_group_link("ElVisualLine", "Statusline")
    highlight_group_link("ElVisual", "Statusline")

    highlight_group_link("ElCommandInactive", "ElCommand")
    highlight_group_link("ElCommandCVInactive", "ElCommandCV")
    highlight_group_link("ElCommandExInactive", "ElCommandEx")
    highlight_group_link("ElConfirmInactive", "ElConfirm")
    highlight_group_link("ElInsertCompletionInactive", "ElInsertCompletion")
    highlight_group_link("ElInsertInactive", "ElInsert")
    highlight_group_link("ElMoreInactive", "ElMore")
    highlight_group_link("ElNormalInactive", "ElNormal")
    highlight_group_link("ElNormalOperatorPendingInactive", "ElNormalOperatorPending")
    highlight_group_link("ElPromptInactive", "ElPrompt")
    highlight_group_link("ElReplaceInactive", "ElReplace")
    highlight_group_link("ElSBlockInactive", "ElSBlock")
    highlight_group_link("ElSelectInactive", "ElSelect")
    highlight_group_link("ElShellInactive", "ElShell")
    highlight_group_link("ElSLineInactive", "ElSLine")
    highlight_group_link("ElTermInactive", "ElTerm")
    highlight_group_link("ElVirtualReplaceInactive", "ElVirtualReplace")
    highlight_group_link("ElVisualBlockInactive", "ElVisualBlock")
    highlight_group_link("ElVisualLineInactive", "ElVisualLine")
    highlight_group_link("ElVisualInactive", "ElVisual")
  end,
})

vim.api.nvim_exec_autocmds("ColorScheme", { group = group })
