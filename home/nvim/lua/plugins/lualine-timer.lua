local M = {}

-- Your existing timer logic
local function timer()
  local file = io.open(os.getenv("HOME") .. "/nix/nixos/extras/timer-state", "r")
  if file then
    local start_time = file:read("*all")
    file:close()
    start_time = start_time:gsub("%s+", "") -- trim whitespace
    if start_time ~= "" and start_time ~= "0" then
      local elapsed = os.time() - tonumber(start_time)
      local hours = math.floor(elapsed / 3600)
      local minutes = math.floor((elapsed % 3600) / 60)
      local seconds = elapsed % 60

      if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds)
      elseif minutes > 0 then
        return string.format("%d:%02d", minutes, seconds)
      else
        return string.format("%ds", seconds)
      end
    end
  end
  return ""
end

M.timer = timer

-- Create and start a repeating timer to refresh lualine every second
local function start_lualine_refresh()
  if M._timer then
    return -- avoid creating multiple timers
  end
  local t = vim.loop.new_timer()
  t:start(0, 1000, vim.schedule_wrap(function()
    -- Force a full redraw of the tabline
    vim.cmd('redrawtabline')
  end))
  M._timer = t
end

M.start_refresh = start_lualine_refresh

return M
