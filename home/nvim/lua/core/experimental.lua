vim.keymap.set("n", "<leader>r", [[<Cmd>luafile %<CR>]], {})

vim.keymap.set("n", "<leader>h", function()
  vim.cmd("edit ~/base/today.vibe")
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

local function show_window_switcher()
  -- Create a new scratch buffer in the current window
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "vibe"
  vim.bo.modifiable = true

  -- Get focused window info
  local focused_res = vim.system({ "niri", "msg", "-j", "focused-window" }):wait()
  local focused_json = vim.json.decode(focused_res.stdout)
  local focused_ws = focused_json and focused_json.workspace_id

  if not focused_ws then
    print("Couldn't determine workspace_id")
    return
  end

  -- Build jq command to filter windows from other workspaces only
  local cmd = string.format(
    [[niri msg --json windows | jq -r '.[] | select(.workspace_id != %d) | "> \(.title) win:\(.id)"']],
    focused_ws
  )

  -- Run it
  local output = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Error fetching niri windows" })
    return
  end

  -- Fill buffer with output
  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
end

-- Create the command
vim.api.nvim_create_user_command("WindowSwitcher", show_window_switcher, {})

-- Focus window by app filename
vim.api.nvim_create_user_command("FocusApp", function(opts)
  local target = opts.args
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match(target) then
      vim.cmd("noautocmd call nvim_set_current_win(" .. win .. ")")
      return
    end
  end
  print("Window not found: " .. target)
end, { nargs = 1 })

-- Close window by app filename
vim.api.nvim_create_user_command("CloseApp", function(opts)
  local target = opts.args
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match(target) then
      vim.api.nvim_win_close(win, false)
      -- sleep 100ms
      vim.wait(100)
      vim.cmd("ProcessAllWindows")
      return
    end
  end
  print("Window not found: " .. target)
end, { nargs = 1 })

-- Focus window relative to app filename
local function focus_relative_to_app(target, direction)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match(target) then
      -- Set current window to the app window first, without triggering autocmds
      vim.cmd("noautocmd call nvim_set_current_win(" .. win .. ")")
      -- Then move in the specified direction
      vim.cmd("wincmd " .. direction)
      -- trigger bufenter for focused window in case its the last window
      vim.cmd("doautocmd BufEnter")
      return
    end
  end
  print("Window not found: " .. target)
end

vim.api.nvim_create_user_command("LeftOfApp", function(opts)
  focus_relative_to_app(opts.args, "h")
end, { nargs = 1 })

vim.api.nvim_create_user_command("RightOfApp", function(opts)
  focus_relative_to_app(opts.args, "l")
end, { nargs = 1 })

vim.api.nvim_create_user_command("AboveApp", function(opts)
  focus_relative_to_app(opts.args, "k")
end, { nargs = 1 })

vim.api.nvim_create_user_command("BelowApp", function(opts)
  focus_relative_to_app(opts.args, "j")
end, { nargs = 1 })

-- Keep the keymap
vim.keymap.set("n", "<leader>w", show_window_switcher, { desc = "List and focus Niri windows" })

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
  -- local res                    = vim.system({ "niri", "msg", "-j", "focused-window" }):wait()
  -- if res.code ~= 0 then
  --   vim.notify("Failed to get Niri window info", vim.log.levels.ERROR)
  --   return
  -- end
  -- local info         = vim.json.decode(res.stdout)
  -- local win_w, win_h = info.layout.window_size[1], info.layout.window_size[2]
  -- Use active output for window dimensions
  local res                    = vim.system({ "niri", "msg", "-j", "focused-output" }):wait()
  local info                   = vim.json.decode(res.stdout)
  local win_w                  = info.logical.width
  local win_h                  = info.logical.height

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

local function send_niri_ipc_batch(actions)
  local socket_path = vim.env.NIRI_SOCKET
  if not socket_path then
    vim.notify("NIRI_SOCKET not set", vim.log.levels.ERROR)
    return false
  end

  -- Connect to the UNIX socket
  local socket = vim.uv.new_pipe(false)
  if not socket then
    vim.notify("Failed to create socket", vim.log.levels.ERROR)
    return false
  end

  local connected = false
  local connect_err = nil

  socket:connect(socket_path, function(err)
    if err then
      connect_err = err
    else
      connected = true
    end
  end)

  -- Wait for connection
  vim.wait(1000, function() return connected or connect_err end)

  if connect_err then
    vim.notify("Failed to connect to niri socket: " .. connect_err, vim.log.levels.ERROR)
    socket:close()
    return false
  end

  -- Send all actions and collect responses
  local responses = {}
  for i, action in ipairs(actions) do
    local request = vim.json.encode({ Action = action }) .. "\n"
    local response_received = false
    local response_data = ""

    socket:write(request, function(err)
      if err then
        vim.notify("Write error: " .. err, vim.log.levels.ERROR)
        response_received = true
      end
    end)

    socket:read_start(function(err, data)
      if err then
        vim.notify("Read error: " .. err, vim.log.levels.ERROR)
        response_received = true
      elseif data then
        response_data = response_data .. data
        if data:find("\n") then
          response_received = true
          table.insert(responses, vim.json.decode(response_data:match("^(.-)%s*$")))
        end
      end
    end)

    -- Wait for response
    vim.wait(1000, function() return response_received end)
  end

  socket:close()
  return responses
end

local function move_window_to_neovim_bounds(id, win)
  local b = get_window_pixel_bounds(win)
  if not b then return end
  local w, h = math.floor(b.nvim_size[1]), math.floor(b.nvim_size[2])
  local x, y = math.floor(b.offset[1]), math.floor(b.offset[2])

  local actions = {
    { MoveWindowToFloating = { id = id } },
    { MoveFloatingWindow = { id = id, x = x, y = y } },
    { SetWindowWidth = { id = id, change = { SetFixed = w } } },
    { SetWindowHeight = { id = id, change = { SetFixed = h } } },
    { MoveWindowToWorkspace = { window_id = id, reference = { Name = "home" }, focus = false } },
  }

  send_niri_ipc_batch(actions)
end

-- Command to process all windows (same logic as WinResized)
vim.api.nvim_create_user_command("ProcessAllWindows", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- Check if window is still valid
    if vim.api.nvim_win_is_valid(win) then
      local bufnr = vim.api.nvim_win_get_buf(win)
      if vim.bo[bufnr].filetype == "app" then
        local id = get_niri_id_from_filename(bufnr)
        if id then
          move_window_to_neovim_bounds(id, win)
        end
      end
    end
  end
end, {})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*.app",
  group = vim.api.nvim_create_augroup("app-buffer-niri", { clear = true }),
  callback = function(args)
    local id = get_niri_id_from_filename(args.buf)
    if not id then return end
    vim.cmd("ProcessAllWindows")
    vim.system({ "niri", "msg", "action", "focus-window", "--id", tostring(id) })
  end,
})


vim.api.nvim_create_autocmd("WinResized", {
  group = vim.api.nvim_create_augroup("app-window-resize", { clear = true }),
  callback = function()
    vim.cmd("ProcessAllWindows")
  end,
})

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("ProcessAllWindows")
end, { desc = "refresh layout in case of issues" })

vim.keymap.set("n", "<CR>", function()
  local line = vim.api.nvim_get_current_line()
  local last_word = line:match("%S+%s*$")

  -- handle content between brackets [...]
  local bracket_content = line:match("%[(.-)%]")
  if bracket_content then
    local vibe_path = vim.fn.expand("~/base/" .. bracket_content .. ".vibe")

    -- Create the file if it doesn't exist
    if vim.fn.filereadable(vibe_path) == 0 then
      vim.fn.writefile({}, vibe_path)
    end

    vim.cmd(":edit " .. vibe_path)
    return
  end

  if vim.startswith(line, '>') then
    local content = last_word

    -- handle windows
    local win_num = content:match("^win:(%d+)")
    if win_num then
      vim.cmd(":edit ~/windows/" .. tostring(win_num) .. ".app")
      return
    end

    local path = vim.fn.expand(content)
    -- handle file paths
    if vim.fn.filereadable(path) == 1 then
      vim.cmd(":edit " .. path)
      return
    end
    -- handle directories
    if vim.fn.isdirectory(path) == 1 then
      print("Opening directory: " .. content)
      vim.cmd(":edit " .. path)
      return
    end
  end
end, {})

-- Delete all buffers not currently visible in any window
vim.api.nvim_create_user_command("BufDeleteHidden", function()
  -- Get all buffers currently visible in windows
  local visible_bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible_bufs[vim.api.nvim_win_get_buf(win)] = true
  end

  -- Delete all loaded buffers that aren't visible
  local deleted = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and not visible_bufs[buf] then
      pcall(vim.api.nvim_buf_delete, buf, {})
      deleted = deleted + 1
    end
  end

  print("Deleted " .. deleted .. " hidden buffer(s)")
end, {})

vim.api.nvim_create_user_command("TimerStart", function()
  vim.fn.system("sh ~/nix/nixos/extras/timer.sh restart")
end, {})

vim.api.nvim_create_user_command("TimerDone", function()
  local timer_state_path = vim.fn.expand("~/nix/nixos/extras/timer-state")

  -- Read the timer state
  local f = io.open(timer_state_path, "r")
  if not f then
    print("Timer not running")
    return
  end

  local start_time = f:read("*n")
  f:close()

  if not start_time or start_time == 0 then
    print("Timer not running")
    return
  end

  -- Calculate elapsed time
  local current_time = os.time()
  local elapsed_seconds = current_time - start_time
  local minutes = math.floor(elapsed_seconds / 60)
  local seconds = elapsed_seconds % 60

  -- Format the time string
  local time_str = string.format(" - %d:%02d", minutes, seconds)

  -- Get the current line and check if it has an unchecked checkbox
  local line = vim.api.nvim_get_current_line()
  if line:find("- %[ %]") then
    line = line:gsub("- %[ %]", "- [x]")
  end

  -- Append to the end of the line
  vim.api.nvim_set_current_line(line .. time_str)

  -- Stop the timer
  vim.fn.system("sh ~/nix/nixos/extras/timer.sh stop")

  print("Timer stopped: " .. time_str)
end, {})

vim.keymap.set("n", "<leader>ts", ":TimerStart<CR>", { desc = "Start timer" })
vim.keymap.set("n", "<leader>td", ":TimerDone<CR>", { desc = "Stop timer and append time" })

-- Toggle maximize/restore focused split
local maximized_state = nil

local function toggle_maximize_split()
  if maximized_state then
    -- Restore previous layout
    vim.cmd(maximized_state)
    maximized_state = nil
  else
    -- Save current layout and maximize
    maximized_state = vim.fn.winrestcmd()
    vim.cmd("wincmd |") -- maximize width
    vim.cmd("wincmd _") -- maximize height
  end
end

vim.api.nvim_create_user_command("ToggleMaximize", toggle_maximize_split, {})
vim.keymap.set("n", "<leader>m", toggle_maximize_split, { desc = "Toggle maximize split" })
