
local M = {}
local state = { buf = nil, win = nil }

local function open_float()
  local ui       = vim.api.nvim_list_uis()[1]
  local width    = math.floor(ui.width  * 0.8)
  local height   = math.floor(ui.height * 0.8)
  local col      = math.floor((ui.width  - width ) / 2)
  local row      = math.floor((ui.height - height) / 2)

  state.buf = vim.api.nvim_create_buf(false, true)        -- NEW empty buffer
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width    = width,
    height   = height,
    col      = col,
    row      = row,
    anchor   = "NW",
    style    = "minimal",
    border   = "rounded",
  })
  vim.api.nvim_win_set_option(state.win, "winhl",
    "Normal:NormalFloat,FloatBorder:FloatBorder")
end

function M.submit()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to submit", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")

  -- (re)open the floating terminal
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    open_float()
  else
    vim.api.nvim_set_current_win(state.win)
    vim.api.nvim_set_current_buf(state.buf)
  end

  -- IMPORTANT -- run termopen **before** anything is written to the buffer
  vim.fn.termopen({ "pyforces", "submit", "-f", file })
  vim.cmd("startinsert")                                  -- jump into terminal
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf = nil, nil
end

return M
