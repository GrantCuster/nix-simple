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
vim.keymap.set("t", "<C-i>", [[<C-\><C-n><C-i>]], opts)

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

-- open splits
vim.keymap.set({ "n", "t" }, "<C-e>", function()
  vim.cmd("split")
  vim.cmd("wincmd j")
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
  vim.cmd("wincmd l")
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

-- Keep last yanked when pasting
vim.keymap.set("v", "p", '"_dP', opts)


-- Open terminal with enter
vim.keymap.set("n", "<C-enter>", function()
  local vim_dir = vim.fn.expand("%:p:h")
  vim_dir = vim_dir:gsub("^oil://", "")
  vim_dir = vim_dir:gsub("/v:null", "")
  vim.cmd("terminal fish -C 'cd " .. vim_dir .. "'")
end, { noremap = true })

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

-- jump back to previous buffer
vim.keymap.set("n", "<leader>bb", ":edit #<CR>")
vim.keymap.set({ "n", "i", "t" }, "<C-b>", [[<Cmd>edit #<CR>]], { noremap = true })

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

-- Function to toggle through active terminal buffers
function Toggle_terminal_buffers()
  local terminal_buffers = get_terminal_buffers_with_active({ "fish" })
  if #terminal_buffers == 0 then
    print("No terminal buffers open")
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  for i, buf in ipairs(terminal_buffers) do
    if buf == current_buf then
      local next_buf = terminal_buffers[(i % #terminal_buffers) + 1]
      vim.api.nvim_set_current_buf(next_buf)
      return
    end
  end

  -- If current buffer is not a terminal, switch to the first terminal buffer
  vim.api.nvim_set_current_buf(terminal_buffers[1])
end

vim.keymap.set({ "n", "t" }, "<C-t>", "<Cmd>lua Toggle_terminal_buffers()<CR>", { noremap = true, silent = true })

-- Bind <CR> to focus the selected window
-- vim.keymap.set("n", "<CR>", function()
--   local line = vim.api.nvim_get_current_line()
--   local wid = line:match("^w(%d+)")
--   -- strip w
--   local id = string.sub(wid, 1)
--   if not id then
--     print("No ID found on line")
--     return
--   end
--
--   -- Sync call
--   local res = vim.system({ "niri", "msg", "--json", "focused-window" }):wait()
--   if res.code ~= 0 then
--     vim.notify("niri failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
--     return
--   end
--   local current_id = tonumber((vim.json.decode(res.stdout) or {}).id)
--
--
--   vim.fn.jobstart({ "niri", "msg", "action", "focus-window", "--id", id }, {
--     detach = true,
--     on_exit = function(_, code)
--       if code == 0 then
--         print("Focused window " .. id)
--         -- delay before returning focus
--         vim.defer_fn(function()
--           vim.fn.jobstart({ "niri", "msg", "action", "focus-window", "--id", tostring(current_id) }, {
--             detach = true,
--             on_exit = function(_, code2)
--               if code2 == 0 then
--                 print("Refocused window " .. current_id)
--               else
--                 print("Failed to refocus " .. current_id)
--               end
--             end,
--           })
--         end, 0) -- delay in ms
--       else
--         print("Failed to focus window " .. id)
--       end
--     end,
--   })
-- end, { desc = "Focus window by ID" })


vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("terminal-title-cwd", { clear = true }),
  callback = function()
    local function set_title_to_cwd()
      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      -- Send OSC 0 sequence to set terminal title
      io.write(string.format("\027]0;%s\007", cwd))
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
