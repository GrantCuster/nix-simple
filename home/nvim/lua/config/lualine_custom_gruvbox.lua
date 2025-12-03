local background = vim.opt.background:get()

print("lualine_custom_gruvbox: background is " .. background)
print("lualine_custom_gruvbox: loading theme config.lualine_custom_gruvbox_" .. background)

return require('config.lualine_custom_gruvbox_' .. background)
