local win_id = vim.api.nvim_get_current_win()

-- Get position
local position = vim.api.nvim_win_get_position(win_id)
local x = position[1]
local y = position[2]

-- Get dimensions
local width = vim.api.nvim_win_get_width(win_id)
local height = vim.api.nvim_win_get_height(win_id)

print("Window Position: ", x, y)
print("Window Dimensions: ", width, height)
