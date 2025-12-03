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
          tabline = {
            lualine_a = {
              {
                vibe_todo,
              },
            },
            lualine_b = {
              {
                require("plugins.lualine-timer").timer,
              },
            },
            lualine_c = {},
            lualine_x = {
              {
                minimized_apps,
              },
              {
                focus_mode,
                color = { fg = "#98871a" }
              }
            },
            lualine_y = {
              {
                battery,
              },
            },
            lualine_z = {
              {
                date,
                color = { fg = "#fabd2f" },
              },
              {
                clock,
              },
            },
          },
        })

    -- -- Configure winbar to show filename at the top of each buffer
    -- vim.opt.winbar = "%{%v:lua.require'lualine'.winbar()%}"
    --
    -- require("lualine").setup({
    --   winbar = {
    --     lualine_a = {
    --       {
    --         'filename',
    --         path = 1,  -- 1 = relative path
    --         file_status = false,  -- Don't show file status indicators
    --         cond = function()
    --           -- Only show winbar for non-terminal buffers
    --           return vim.bo.buftype ~= 'terminal'
    --         end
    --       }
    --     },
    --     lualine_x = {},
    --     lualine_y = {},
    --     lualine_z = {}
    --   },
    --   inactive_winbar = {
    --     lualine_a = {
    --       {
    --         'filename',
    --         path = 1,  -- 1 = relative path
    --         file_status = false,
    --         cond = function()
    --           return vim.bo.buftype ~= 'terminal'
    --         end
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
