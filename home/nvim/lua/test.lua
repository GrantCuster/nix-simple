local win_id = vim.api.nvim_get_current_win()

-- Get position
local position = vim.api.nvim_win_get_position(win_id)
local col = position[2]
local row = position[1]

-- Get dimensions
local widthCols = vim.api.nvim_win_get_width(win_id)
local heightRows = vim.api.nvim_win_get_height(win_id)

local charWidth = 10
local charHeight = 22

local x = col * charWidth + 4
local y = row * charHeight
local width = widthCols * charWidth
local height = heightRows * charHeight

os.execute("google-chrome-stable --hide-crash-restore-bubble --new-window --app=https://garden.grantcuster.com &")
os.execute("sleep 0.3 && ~/.config/niri/scripts/nvim_browser.sh " .. x .. " " .. y .. " " .. width .. " " .. height)
