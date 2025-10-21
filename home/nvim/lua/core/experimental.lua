vim.keymap.set("n", "<leader>r", [[<Cmd>luafile %<CR>]], {})

function MoveToSplitBelow()
  local current_win = vim.api.nvim_get_current_win()

  -- Try to move to window below
  vim.cmd("wincmd j")
  local below_win = vim.api.nvim_get_current_win()

  -- If we're still in the same window, there's no split below
  if current_win == below_win then
    -- Create new split and move to it
    vim.cmd("split")
    vim.cmd("wincmd j")
  end
end

vim.keymap.set("n", "<leader>h", function()
  vim.cmd("edit ~/base/base.vibe")
end, {})


vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "/home/grant/base/*",
  group = vim.api.nvim_create_augroup("base-buffer-settings", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})


vim.filetype.add({
  extension = {
    vibe = "vibe",
  },
})

vim.keymap.set("n", "<leader>w", function()
  -- Create a new scratch buffer in the current window
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "vibe"
  vim.bo.modifiable = true

  -- Run niri + jq to get window list
  local output = vim.fn.systemlist(
    [[niri msg --json windows | jq -r '.[] | "> \(.title) win:\(.id)"']]
  )

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Error fetching niri windows" })
    return
  end

  -- Fill buffer with output
  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
end, { desc = "List and focus Niri windows" })

vim.filetype.add({
  extension = {
    app = "app",
  },
})

-- ~/.config/nvim/ftplugin/app.lua
local function get_niri_id_from_filename(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return tonumber(name:match("([^/]+)%.app$"))
end

vim.keymap.set({ "n", "i" }, "<C-c>", function()
	-- Get the current line
	local current_line = vim.fn.getline(".")
	-- Get the current line number
	local line_number = vim.fn.line(".")
	if current_line:find("%- %[ %]") then
		local new_line = current_line:gsub("%- %[ %]", "- [x]")
		vim.fn.setline(line_number, new_line)
	elseif current_line:find("%- %[x%]") then
		local new_line = current_line:gsub("%- %[x%] ", "")
		vim.fn.setline(line_number, new_line)
	else
		vim.fn.setline(line_number, "- [ ] " .. current_line)
	end
end, { desc = "Toggle task done or not" })



local function get_window_pixel_bounds(win)
  local padding                = 8

  -- window geometry (in chars)
  local width_chars            = vim.api.nvim_win_get_width(win)
  local height_chars           = vim.api.nvim_win_get_height(win)
  local pos                    = vim.api.nvim_win_get_position(win)

  -- total Neovim UI (entire terminal)
  local ui                     = vim.api.nvim_list_uis()[1]
  local total_cols, total_rows = ui.width, ui.height

  -- get Niri window size (pixels)
  local res                    = vim.system({ "niri", "msg", "-j", "focused-window" }):wait()
  if res.code ~= 0 then
    vim.notify("Failed to get Niri window info", vim.log.levels.ERROR)
    return
  end
  local info = vim.json.decode(res.stdout)
  local win_w, win_h = info.layout.window_size[1], info.layout.window_size[2]

  -- local win_w                  = 1736
  -- local win_h                  = 1157

  -- usable area minus Ghostty padding
  local inner_w                = win_w - (padding * 2)
  local inner_h                = win_h - (padding * 2)

  -- pixels per cell
  local cell_w                 = inner_w / total_cols
  local cell_h                 = inner_h / total_rows

  -- this window’s pixel size + offset
  local px_w                   = width_chars * cell_w
  local px_h                   = height_chars * cell_h + 8
  local offset_x               = padding + pos[2] * cell_w
  local offset_y               = padding + pos[1] * cell_h - 8

  return {
    nvim_size = { px_w, px_h },
    offset = { offset_x, offset_y },
  }
end

local function move_window_to_neovim_bounds(id, win)
  local b = get_window_pixel_bounds(win)
  if not b then return end
  local w, h = math.floor(b.nvim_size[1]), math.floor(b.nvim_size[2])
  local x, y = math.floor(b.offset[1]), math.floor(b.offset[2])

  local cmds = {
    { "niri", "msg", "action", "move-floating-window",     "--id",    tostring(id), "--x",         tostring(x),  "--y", tostring(y) },
    { "niri", "msg", "action", "set-window-width",         "--id",    tostring(id), tostring(w) },
    { "niri", "msg", "action", "set-window-height",        "--id",    tostring(id), tostring(h) },
    { "niri", "msg", "action", "move-window-to-floating",  "--id",    tostring(id) },
    { "niri", "msg", "action", "move-window-to-workspace", "--focus", "false",      "--window-id", tostring(id), "home" },
  }

  for _, c in ipairs(cmds) do vim.system(c) end
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*.app",
  group = vim.api.nvim_create_augroup("app-buffer-niri", { clear = true }),
  callback = function(args)
    local result = vim.fn.systemlist("niri msg -j focused-window | jq -r '.id'")
    if vim.v.shell_error ~= 0 or #result == 0 then
      print("Error: Could not get focused window ID")
      return
    end
    local nvim_id = result[1]
    local id = get_niri_id_from_filename(args.buf)
    -- if not id then return end
    move_window_to_neovim_bounds(id, vim.api.nvim_get_current_win())
    vim.system({ "niri", "msg", "action", "focus-window", "--id", tostring(id) })

    -- Store window ID and vim socket in tmp file
    local socket = vim.v.servername
    local tmp_file = "/tmp/nvim_app.txt"
    local file = io.open(tmp_file, "w")
    if file then
      file:write(string.format("window_id=%s\nsocket=%s\n", tostring(nvim_id), socket))
      file:close()
    end
  end,
})


vim.api.nvim_create_autocmd("WinResized", {
  group = vim.api.nvim_create_augroup("app-window-resize", { clear = true }),
  callback = function()
    local windows = vim.v.event.windows or {}
    for _, win in ipairs(windows) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      if vim.bo[bufnr].filetype == "app" then
        local id = get_niri_id_from_filename(bufnr)
        if id then
          move_window_to_neovim_bounds(id, win)
        end
      end
    end
  end,
})

vim.keymap.set("n", "<CR>", function()
  local line = vim.api.nvim_get_current_line()
  local last_word = line:match("%S+%s*$")

  if vim.startswith(line, '>') then
    local content = last_word

    -- handle windows
    local win_num = content:match("^win:(%d+)")
    if win_num then
      vim.cmd(":edit ~/windows/" .. tostring(win_num) .. ".app")
      return
    end

    print("Found content: " .. content)
    local path = vim.fn.expand(content)
    -- handle file paths
    if vim.fn.filereadable(path) == 1 then
      -- MoveToSplitBelow()
      vim.cmd(":edit " .. path)
      return
    end
    -- handle directories
    if vim.fn.isdirectory(path) == 1 then
      print("Opening directory: " .. content)
      -- MoveToSplitBelow()
      vim.cmd(":edit " .. path)
      return
    end
  end
end, {})
