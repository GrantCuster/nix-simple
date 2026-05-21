return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local function cwd()
      local full_path = vim.loop.cwd()
      return full_path:match("([^/]+)$") -- Extract the last part of the string after "/"
    end
    local function project_name()
      local buf_ft = vim.bo.filetype -- Get the current buffer's filetype

      -- Skip if the buffer is a Telescope buffer
      if buf_ft == "TelescopePrompt" then
        return ""
      end

      local target_dir = nil

      -- Check if the buffer is a terminal
      if vim.bo.buftype == "terminal" then
        local bufname = vim.api.nvim_buf_get_name(0)
        local pwd = bufname:match("term://(.-)::")
        if pwd then
          target_dir = pwd
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
            target_dir = vim.fn.fnamemodify(project_dir, ":h")
          elseif git_dir ~= "" then
            target_dir = vim.fn.fnamemodify(git_dir, ":h")
          else
            target_dir = oil_path
          end
        end
      else
        -- Handle non-Oil buffers
        local bufname = vim.api.nvim_buf_get_name(0) -- Get the buffer's name (path)
        if bufname ~= "" then
          local buf_dir = vim.fn.fnamemodify(bufname, ":h")
          local project_dir = vim.fn.finddir(".project", buf_dir .. ";")
          local git_dir = vim.fn.finddir(".git", buf_dir .. ";")

          if project_dir ~= "" then
            target_dir = vim.fn.fnamemodify(project_dir, ":h")
          elseif git_dir ~= "" then
            target_dir = vim.fn.fnamemodify(git_dir, ":h")
          else
            target_dir = buf_dir
          end
        end
      end

      -- Return the project name (last component of the directory)
      if target_dir then
        return target_dir:match("([^/]+)$") or ""
      end
      return ""
    end
    local function date()
      return os.date("%Y-%m-%d")
    end
    local function clock()
      return os.date("%-I:%02M %p")
    end
    local function battery()
      local file = io.open("/sys/class/power_supply/BAT1/capacity", "r")
      local statusFile = io.open("/sys/class/power_supply/BAT1/status", "r")
      if file and statusFile then
        local capacity = file:read("*all")
        file:close()
        status = statusFile:read("*all")
        capacity = capacity:gsub("%s+", "") -- trim whitespace
        statusText = status == "Charging\n" and "+" or "-"
        if capacity and capacity ~= "" then
          return statusText .. capacity
        end
      end
      return "BAT?"
    end
    local function focus_mode()
      local file = io.open(os.getenv("HOME") .. "/nix/nixos/extras/focus-state", "r")
      if file then
        local state = file:read("*all")
        file:close()
        state = state:gsub("%s+", "") -- trim whitespace
        if state == "on" then
          return "focus"
        end
      end
      return ""
    end
    local function minimized_apps()
      local cmd = "niri msg --json windows | jq 'length - 1'"
      local count = vim.fn.system(cmd)
      return vim.trim(count)
    end
    -- Cache for active_terminals with 5-second TTL
    local active_terminals_cache = { count = 0, last_update = 0 }
    local function active_terminals()
      local now = vim.loop.now()
      local cache_ttl = 5000 -- 5 seconds in milliseconds

      -- Return cached value if still fresh
      if now - active_terminals_cache.last_update < cache_ttl then
        return active_terminals_cache.count > 0 and active_terminals_cache.count or "0"
      end

      -- Update cache
      local count = 0

      -- Get all terminal buffers first
      local terminal_pids = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
            and vim.api.nvim_buf_get_option(buf, "buftype") == "terminal"
        then
          local job_id = vim.b[buf].terminal_job_id
          if job_id and job_id > 0 then
            local shell_pid = vim.fn.jobpid(job_id)
            if shell_pid and shell_pid > 0 then
              table.insert(terminal_pids, shell_pid)
            end
          end
        end
      end

      -- Early exit if no terminals
      if #terminal_pids == 0 then
        active_terminals_cache.count = 0
        active_terminals_cache.last_update = now
        return "0"
      end

      -- Single ps call for all terminals
      local h = io.popen("ps -eo pid=,ppid=,comm=")
      if h then
        local data = h:read("*a") or ""
        h:close()

        -- Build process tree once
        local kids = {}
        for pid_s, ppid_s, comm in data:gmatch("(%d+)%s+(%d+)%s+([^\n]+)") do
          local pid, ppid = tonumber(pid_s), tonumber(ppid_s)
          if pid and ppid then
            kids[ppid] = kids[ppid] or {}
            table.insert(kids[ppid], { pid = pid, comm = comm })
          end
        end

        local function base(name) return (name or ""):gsub(".-([^/]+)$", "%1") end
        local ignore = { fish = true }

        -- Check each terminal using the shared process tree
        for _, shell_pid in ipairs(terminal_pids) do
          local stack = { shell_pid }
          local has_active = false

          while #stack > 0 do
            local p = table.remove(stack)
            local c = kids[p]
            if c then
              for _, pr in ipairs(c) do
                local name = base(pr.comm)
                if not ignore[name] then
                  has_active = true
                  break
                end
                table.insert(stack, pr.pid)
              end
            end
            if has_active then break end
          end

          if has_active then
            count = count + 1
          end
        end
      end

      active_terminals_cache.count = count
      active_terminals_cache.last_update = now
      return count > 0 and count or "0"
    end
    local function vibe_todo()
      local function get_oblique_strategy()
        local oblique_file = io.open(os.getenv("HOME") .. "/.oblique_strategies", "r")
        if oblique_file then
          local lines = {}
          for line in oblique_file:lines() do
            if line:match("%S") then -- Only include non-blank lines
              table.insert(lines, line)
            end
          end
          -- oblique_file:close()
          -- if #lines > 0 then
          --   -- Use date as seed so it's consistent for the whole day
          --   math.randomseed(tonumber(os.date("%Y%m%d")))
          --   return lines[math.random(#lines)]
          -- end
        end
        return ""
      end

      local file = io.open(os.getenv("HOME") .. "/base/today.vibe", "r")
      if file then
        for line in file:lines() do
          if line:match("^%- %[ %]") then
            file:close()
            local todo_text = line:gsub("^%- %[ %] ", "") -- Remove the "- [ ] " prefix
            -- If the todo text is blank or only whitespace, use an oblique strategy
            if todo_text:match("^%s*$") then
              return get_oblique_strategy()
            end
            return todo_text
          end
        end
        file:close()
      end
      return ""
    end
    filetypes =
        { "oil" }, require("lualine").setup({
          options = {
            icons_enabled = false,
            section_separators = { left = "", right = "" },
            component_separators = { left = "", right = "" },
            -- draw_empty = true,
            globalstatus = true,
            theme = require("config.lualine_custom_gruvbox_dark"), -- Start with dark theme
          },
          sections = {
            lualine_a = { cwd, "branch", "diff" },
            lualine_b = { { "filename", path = 4 } },
            lualine_c = {},
            lualine_x = {},
            lualine_y = { "filetype" },
            lualine_z = { { "mode" } },
          },
          -- tabline = {
          --   lualine_a = {
          --     {
          --       vibe_todo,
          --     },
          --   },
          --   lualine_b = {
          --     {
          --       require("plugins.lualine-timer").timer,
          --     },
          --   },
          --   lualine_c = {},
          --   lualine_x = {
          --     {
          --       active_terminals,
          --       color = { fg = "#d3869b" }
          --     },
          --     {
          --       minimized_apps,
          --     },
          --     {
          --       focus_mode,
          --       color = { fg = "#98871a" }
          --     }
          --   },
          --   lualine_y = {
          --     {
          --       battery,
          --     },
          --   },
          --   lualine_z = {
          --     {
          --       date,
          --       color = { fg = "#fabd2f" },
          --     },
          --     {
          --       clock,
          --     },
          --   },
          -- },
        })

    -- Configure winbar to show filename at the top of each buffer
    -- vim.opt.winbar = "%{%v:lua.require'lualine'.winbar()%}"

    -- require("lualine").setup({
    --   winbar = {
    --     lualine_a = { project_name },
    --     lualine_b = {
    --       {
    --         'filename',
    --         path = 1,            -- 1 = relative path
    --         file_status = false, -- Don't show file status indicators
    --         cond = function()
    --           -- Only show winbar for non-terminal buffers
    --           return vim.bo.buftype ~= 'terminal'
    --         end,
    --         color = { fg = "#fabd2f" },
    --       }
    --     },
    --     lualine_x = {},
    --     lualine_y = {},
    --     lualine_z = {}
    --   },
    --   inactive_winbar = {
    --     lualine_a = { project_name },
    --     lualine_b = {
    --       {
    --         'filename',
    --         path = 1, -- 1 = relative path
    --         file_status = false,
    --         cond = function()
    --           return vim.bo.buftype ~= 'terminal'
    --         end,
    --         color = { fg = "#fabd2f" },
    --       }
    --     },
    --     lualine_x = {},
    --     lualine_y = {},
    --     lualine_z = {}
    --   },
    -- })

    -- Start the timer refresh after lualine is set up
    require("plugins.lualine-timer").start_refresh()

    -- transparent status
    -- vim.api.nvim_set_hl(0, "StatusLine", { bg = "none", fg = "none" })
  end,
}
