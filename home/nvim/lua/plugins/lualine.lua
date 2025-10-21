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
    filetypes =
        { "oil" }, require("lualine").setup({
          options = {
            icons_enabled = false,
            section_separators = { left = "", right = "" },
            component_separators = { left = "", right = "" },
            draw_empty = true,
            globalstatus = true,
            theme = require("config/lualine_custom_gruvbox"),
          },
          sections = {
            lualine_a = { "branch", "diff" },
            lualine_b = { { "filename", path = 4 } },
            lualine_c = {},
            lualine_x = {},
            lualine_y = { "filetype" },
            lualine_z = { { "mode", padding = { left = 1, right = 0 } } },
          },
          tabline = {
            lualine_a = {
              {
                cwd,
                padding = { left = 1, right = 1 },
              },
            },
            lualine_z = {
              {
                battery,
                padding = { left = 1, right = 1 },
              },
              {
                date,
                padding = { left = 1, right = 1 },
              },
              {
                clock,
                padding = { left = 1, right = 1 },
              },
            },
          },
        })
    -- transparent status
    -- vim.api.nvim_set_hl(0, "StatusLine", { bg = "none", fg = "none" })
  end,
}
