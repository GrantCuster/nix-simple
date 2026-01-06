-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- jk to exit insert mode, in terminal too
vim.keymap.set("i", "jk", "<esc>", opts)
vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

-- save file
vim.keymap.set({ "n", "i" }, "<C-s>", ":wa<CR>", opts)

-- clear search highlight
vim.keymap.set("n", "<esc>", ":noh<CR><esc>", opts)

-- Move between windows using Ctrl + {h,j,k,l}
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)

-- Jump back and forward with Ctrl + o and Ctrl + i
vim.keymap.set("t", "<C-o>", [[<C-\><C-n><C-o>]], opts)
-- Note: <C-i> is the same as <Tab> in terminals, so we don't map it in terminal mode
-- vim.keymap.set("t", "<C-i>", [[<C-\><C-n><C-i>]], opts)

-- LINE NAVIGATION
vim.keymap.set("n", "<down>", "gj", opts)
vim.keymap.set("n", "<up>", "gk", opts)
vim.keymap.set("v", "<down>", "gj", opts)
vim.keymap.set("v", "<up>", "gk", opts)
vim.keymap.set("n", "j", "gj", opts)
vim.keymap.set("n", "k", "gk", opts)
vim.keymap.set("v", "j", "gj", opts)
vim.keymap.set("v", "k", "gk", opts)

-- Open oil - match - in normal
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set({ "n", "t", "i" }, "<C-->", function()
  local cwd = vim.fn.getcwd()
  vim.cmd("edit " .. cwd)
end, { noremap = true, silent = true })

-- quit
vim.keymap.set({ "n", "t", "i" }, "<C-w>", function()
  vim.cmd("q")
end, { noremap = true, silent = true, nowait = true })

-- Copy current path
vim.keymap.set("n", "<leader>cf", ":let @+ = expand('%')<CR>", {})

-- Insert current date
vim.keymap.set("n", "<leader>d", function()
  local date = os.date("%Y-%m-%d")
  vim.api.nvim_put({ date }, "c", true, true)
end, { desc = "Insert current date" })

-- open splits
vim.keymap.set({ "n", "t" }, "<C-e>", function()
  vim.cmd("split")
  -- vim.cmd("wincmd j")
  local buf_ft = vim.bo.filetype
  if vim.bo[0].buftype == "terminal" then
    local cwd = vim.fn.getcwd()
    vim.cmd("terminal fish -C 'cd " .. cwd .. "'")
  elseif buf_ft ~= "oil" then
    -- vim.cmd("Oil")
  end
end, {})
vim.keymap.set({ "n", "t" }, "<C-d>", function()
  vim.cmd("vsplit")
  -- vim.cmd("wincmd l")
  local buf_ft = vim.bo.filetype
  if vim.bo[0].buftype == "terminal" then
    local cwd = vim.fn.getcwd()
    vim.cmd("terminal fish -C 'cd " .. cwd .. "'")
  elseif buf_ft ~= "oil" then
    -- vim.cmd("Oil")
  end
end, {})
vim.keymap.set("n", "<leader><enter>", function()
  local winwidth = vim.fn.winwidth(0) * 0.5
  local winheight = vim.fn.winheight(0)
  local buf_ft = vim.bo.filetype
  if winwidth > winheight then
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
  else
    vim.cmd("split")
    vim.cmd("wincmd j")
  end
  if buf_ft == "terminal" then
    local cwd = vim.fn.getcwd()
    vim.cmd("terminal fish -C 'cd " .. cwd .. "'")
  elseif buf_ft ~= "oil" then
    -- vim.cmd("Oil")
  end
end, {})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', opts)

-- Resize with arrows
vim.keymap.set("n", "<Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", opts)

-- Toggle line wrapping
vim.keymap.set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts)

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Move lines up and down (noremap to override default K hover behavior)
vim.keymap.set("n", "J", ":m .+1<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "K", ":m .-2<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv", { noremap = true, silent = true })

-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)

local function terminal_enter()
  local vim_dir = vim.fn.expand("%:p:h")
  vim_dir = vim_dir:gsub("^oil://", "")
  vim_dir = vim_dir:gsub("/v:null", "")
  vim.cmd("terminal fish -C 'cd " .. vim_dir .. "'")
end

vim.api.nvim_create_user_command("TerminalEnter", terminal_enter, {})

-- Open terminal with enter
vim.keymap.set("n", "<C-enter>", terminal_enter, { noremap = true })

-- Return true iff PID has any descendant whose command name is not in ignore set.
local function has_non_ignored_descendant(root_pid, ignore_list)
  local ignore = {}
  for _, n in ipairs(ignore_list or { "fish" }) do ignore[n] = true end

  local h = io.popen("ps -eo pid=,ppid=,comm=")
  if not h then return false end
  local data = h:read("*a") or ""
  h:close()

  -- parent -> children map
  local kids = {}
  for pid_s, ppid_s, comm in data:gmatch("(%d+)%s+(%d+)%s+([^\n]+)") do
    local pid, ppid = tonumber(pid_s), tonumber(ppid_s)
    if pid and ppid then
      kids[ppid] = kids[ppid] or {}
      table.insert(kids[ppid], { pid = pid, comm = comm })
    end
  end

  local function base(name) return (name or ""):gsub(".-([^/]+)$", "%1") end

  local stack = { root_pid }
  while #stack > 0 do
    local p = table.remove(stack)
    local c = kids[p]
    if c then
      for _, pr in ipairs(c) do
        local name = base(pr.comm)
        if not ignore[name] then
          return true
        end
        table.insert(stack, pr.pid)
      end
    end
  end
  return false
end

vim.keymap.set("t", "<C-enter>", function()
  -- check if process (non-fish is running)
  local job_id = vim.b.terminal_job_id or vim.api.nvim_buf_get_var(0, "terminal_job_id")
  if job_id and job_id > 0 then
    local shell_pid = vim.fn.jobpid(job_id)
    if shell_pid and shell_pid > 0 then
      if has_non_ignored_descendant(shell_pid, { "fish" }) then
        -- there is no process open new terminal
        -- parse from the terminal buffer name the cwd
        local bufname = vim.api.nvim_buf_get_name(0)
        -- example buffname term:///home/grant/dev::1757597042
        -- parse out /home/grant/dev
        local vim_dir = bufname:match("term://(.-)::")
        vim.cmd("terminal fish -C 'cd " .. vim_dir .. "'")
      end
    end
  end
end, { noremap = true })

-- toggle line numbers
vim.keymap.set("n", "<leader>n", ":set number!<CR>:set relativenumber!<CR>", {})

-- toggle distraction free mode
vim.keymap.set(
  "n",
  "<leader>m",
  ":set nonumber<CR>:set norelativenumber<CR>:set nospell<CR>:set signcolumn=no<CR>:set laststatus=0<CR>:set noruler<CR>:set noshowcmd<CR>:echo ''<CR>",
  {}
)

-- Returns terminal buffers that have an active descendant process
-- other than anything in ignore_list (defaults to {"fish"}).
local function get_terminal_buffers_with_active(ignore_list)
  local terminal_buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf)
        and vim.api.nvim_buf_get_option(buf, "buftype") == "terminal"
    then
      local job_id = vim.b[buf].terminal_job_id or vim.api.nvim_buf_get_var(buf, "terminal_job_id")
      if job_id and job_id > 0 then
        local shell_pid = vim.fn.jobpid(job_id)
        if shell_pid and shell_pid > 0 then
          if has_non_ignored_descendant(shell_pid, ignore_list) then
            table.insert(terminal_buffers, buf)
          end
        end
      end
    end
  end
  return terminal_buffers
end

-- Get process name(s) running in a terminal buffer
local function get_terminal_process_name(buf)
  local job_id = vim.b[buf].terminal_job_id
  if not job_id or job_id <= 0 then
    return nil
  end

  local shell_pid = vim.fn.jobpid(job_id)
  if not shell_pid or shell_pid <= 0 then
    return nil
  end

  -- Get process tree
  local h = io.popen("ps -eo pid=,ppid=,comm=")
  if not h then return nil end
  local data = h:read("*a") or ""
  h:close()

  -- Build parent -> children map
  local kids = {}
  for pid_s, ppid_s, comm in data:gmatch("(%d+)%s+(%d+)%s+([^\n]+)") do
    local pid, ppid = tonumber(pid_s), tonumber(ppid_s)
    if pid and ppid then
      kids[ppid] = kids[ppid] or {}
      table.insert(kids[ppid], { pid = pid, comm = comm })
    end
  end

  local function base(name) return (name or ""):gsub(".-([^/]+)$", "%1") end

  -- Find non-fish processes
  local processes = {}
  local ignore = { fish = true }
  local stack = { shell_pid }

  while #stack > 0 do
    local p = table.remove(stack)
    local c = kids[p]
    if c then
      for _, pr in ipairs(c) do
        local name = base(pr.comm)
        if not ignore[name] then
          table.insert(processes, name)
        end
        table.insert(stack, pr.pid)
      end
    end
  end

  if #processes == 0 then
    return "fish"
  elseif #processes == 1 then
    return processes[1]
  else
    return table.concat(processes, " -> ")
  end
end

-- Get terminal directory from buffer name
local function get_terminal_directory(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  -- Parse: term:///home/grant/dev::1757597042
  local dir = bufname:match("term://(.-)::")
  if dir then
    -- Shorten home directory
    dir = dir:gsub("^" .. vim.env.HOME, "~")
    return dir
  end
  return "unknown"
end

-- Show terminal switcher UI
local function show_terminal_switcher()
  -- Save the buffer we came from
  local origin_buf = vim.api.nvim_get_current_buf()

  -- Get all visible buffers in windows
  local visible_bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible_bufs[vim.api.nvim_win_get_buf(win)] = true
  end

  -- Get only active terminal buffers (with non-fish processes) that are not visible
  local all_active_terminals = get_terminal_buffers_with_active({ "fish" })
  local terminal_buffers = {}
  for _, buf in ipairs(all_active_terminals) do
    if not visible_bufs[buf] then
      table.insert(terminal_buffers, buf)
    end
  end

  if #terminal_buffers == 0 then
    print("No hidden active terminal buffers")
    return
  end

  -- Create scratch buffer
  vim.cmd("enew")
  local switcher_buf = vim.api.nvim_get_current_buf()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "terminal-switcher"
  vim.bo.modifiable = true

  -- Build display lines and metadata
  local lines = {}
  local buf_map = {} -- line number -> buffer number

  for i, buf in ipairs(terminal_buffers) do
    local dir = get_terminal_directory(buf)
    local process = get_terminal_process_name(buf)

    local line = string.format("> %s - %s", dir, process or "fish")
    table.insert(lines, line)
    buf_map[i] = buf
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(switcher_buf, 0, -1, false, lines)
  vim.bo.modifiable = false

  -- Store metadata in buffer variable
  vim.b[switcher_buf].terminal_buf_map = buf_map

  -- Set up keymaps for this buffer
  vim.keymap.set("n", "<CR>", function()
    local line_num = vim.fn.line(".")
    local target_buf = vim.b.terminal_buf_map[line_num]

    if target_buf and vim.api.nvim_buf_is_valid(target_buf) then
      -- Close switcher and switch to terminal
      vim.api.nvim_set_current_buf(target_buf)
    else
      print("Invalid terminal buffer")
    end
  end, { buffer = switcher_buf, noremap = true, silent = true })

  vim.keymap.set("n", "q", "<Cmd>bwipeout<CR>", { buffer = switcher_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", "<Cmd>bwipeout<CR>", { buffer = switcher_buf, noremap = true, silent = true })
end

vim.keymap.set({ "n", "t" }, "<C-t>", function()
  -- Exit terminal mode first if we're in it
  if vim.bo.buftype == "terminal" then
    vim.cmd("stopinsert")
  end
  show_terminal_switcher()
end, { noremap = true, silent = true, desc = "Show terminal switcher" })

-- Command launcher configuration
-- Define your commands here as { name = "Display Name", command = "shell command" }
local launcher_commands = {
  { name = "nautilus",      command = "l nautilus ." },
  { name = 'volume',          command = "l pavucontrol" },
  { name = 'work',          command = "l google-chrome-stable --ozone-platform=wayland --profile-directory=Profile\\ 1 --password-store=basic --hide-crash-restore-bubble" },
  { name = "kdenlive",      command = "l kdenlive" },
  { name = "obs",           command = "l obs" },
  { name = "nautilus ~",    command = "l nautilus" },
  { name = "icloud-sync",   command = 'icloudpd --directory ~/icloud-test --username "grantcuster@gmail.com" --recent 8' },
  { name = 'bluetooth',          command = "l blueman-manager" },
  { name = "home-manager",  command = "home-manager --flake .#linux-x86 switch" },
  { name = "nixos-rebuild", command = "sudo nixos-rebuild switch --flake .#framework" },
  { name = "reboot",        command = "sudo reboot" },
}

-- Show command launcher UI
local function show_command_launcher()
  -- Save the buffer we came from
  local origin_buf = vim.api.nvim_get_current_buf()

  if #launcher_commands == 0 then
    print("No commands defined in launcher")
    return
  end

  -- Create scratch buffer
  vim.cmd("enew")
  local launcher_buf = vim.api.nvim_get_current_buf()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "command-launcher"
  vim.bo.modifiable = true

  -- Build display lines and metadata
  local lines = {}
  local cmd_map = {} -- line number -> command

  for i, item in ipairs(launcher_commands) do
    local line = string.format("> %s", item.name)
    table.insert(lines, line)
    cmd_map[i] = item.command
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(launcher_buf, 0, -1, false, lines)
  vim.bo.modifiable = false

  -- Store metadata in buffer variable
  vim.b[launcher_buf].launcher_cmd_map = cmd_map
  vim.b[launcher_buf].launcher_origin_buf = origin_buf

  -- Set up keymaps for this buffer
  vim.keymap.set("n", "<CR>", function()
    local line_num = vim.fn.line(".")
    local command = vim.b.launcher_cmd_map[line_num]

    if command then
      -- Execute the command in the same buffer (replace launcher)
      local cwd = vim.fn.getcwd()
      vim.cmd("terminal fish -C 'cd " .. cwd .. " && " .. command .. "'")
    else
      print("No command found for this line")
    end
  end, { buffer = launcher_buf, noremap = true, silent = true })

  vim.keymap.set("n", "q", "<Cmd>bwipeout<CR>", { buffer = launcher_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", "<Cmd>bwipeout<CR>", { buffer = launcher_buf, noremap = true, silent = true })
end

vim.keymap.set({ "n", "t" }, "<C-a>", function()
  -- Exit terminal mode first if we're in it
  if vim.bo.buftype == "terminal" then
    vim.cmd("stopinsert")
  end
  show_command_launcher()
end, { noremap = true, silent = true, desc = "Show command launcher" })

vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("terminal-title-cwd", { clear = true }),
  callback = function()
    local function set_title_to_cwd()
      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      -- Send OSC 0 sequence to set terminal title
      io.write(string.format("\027]0;%s\007", "vim - " .. cwd))
      io.flush()
    end
    set_title_to_cwd()
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("buffer-cwd-management", { clear = true }),
  callback = function()
    local buf_ft = vim.bo.filetype -- Get the current buffer's filetype

    -- Skip if the buffer is a Telescope buffer
    if buf_ft == "TelescopePrompt" then
      return
    end

    -- Check if the buffer is a terminal
    if vim.bo.buftype == "terminal" then
      local bufname = vim.api.nvim_buf_get_name(0)
      local pwd = bufname:match("term://(.-)::")
      if pwd then
        vim.api.nvim_set_current_dir(pwd)
      end
    elseif buf_ft == "oil" then
      -- The buffer is an Oil buffer
      local oil = require("oil")
      local oil_path = oil.get_current_dir() -- Get the directory associated with the Oil buffer
      if oil_path then
        -- Check if this directory or its parents contain a .project or .git directory
        local project_dir = vim.fn.finddir(".project", oil_path .. ";")
        local git_dir = vim.fn.finddir(".git", oil_path .. ";")

        if project_dir ~= "" then
          local target_dir = vim.fn.fnamemodify(project_dir, ":h")
          vim.api.nvim_set_current_dir(target_dir)
        elseif git_dir ~= "" then
          local target_dir = vim.fn.fnamemodify(git_dir, ":h")
          vim.api.nvim_set_current_dir(target_dir)
        elseif oil_path ~= "v:null" then
          -- Default to Oil's path if neither .project nor .git is found
          -- vim.api.nvim_set_current_dir(oil_path)
        end
      end
    else
      -- Handle non-Oil buffers
      local project_dir = vim.fn.finddir(".project", ".;")
      local git_dir = vim.fn.finddir(".git", ".;")

      if project_dir ~= "" then
        local target_dir = vim.fn.fnamemodify(project_dir, ":h")
        vim.api.nvim_set_current_dir(target_dir)
      elseif git_dir ~= "" then
        local target_dir = vim.fn.fnamemodify(git_dir, ":h")
        vim.api.nvim_set_current_dir(target_dir)
      else
        -- Set the parent directory as the working directory if no .project or .git directory is found
        local bufname = vim.api.nvim_buf_get_name(0) -- Get the buffer's name (path)
        if bufname ~= "" then
          local parent_dir = vim.fn.fnamemodify(bufname, ":h")
          if parent_dir ~= "" then
            vim.api.nvim_set_current_dir(parent_dir)
          end
        end
      end
    end
  end,
})
