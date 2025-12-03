local M = {}

-- reads from ~/.cache/theme-mode if present
local function read_state()
	local f = io.open(vim.fn.expand("~/.cache/theme-mode"), "r")
	if not f then
		return "dark"
	end
	local mode = f:read("*l")
	f:close()
	return mode or "dark"
end

function M.apply(mode)
	print("🎨 theme.lua: applying mode = " .. mode)

	if mode == "light" then
		vim.o.background = "light"
		vim.cmd([[colorscheme gruvbox]])
	else
		vim.o.background = "dark"
		vim.cmd([[colorscheme gruvbox]])
	end

	print("🎨 theme.lua: background is now " .. vim.o.background)

	-- Make sign column match background
	vim.cmd([[highlight SignColumn guibg=NONE ctermbg=NONE]])

		local theme = mode == "dark"
			and require("config.lualine_custom_gruvbox_dark")
			or require("config.lualine_custom_gruvbox_light")

		local lualine = require("lualine")
		local config = lualine.get_config()
		config.options.theme = theme
		lualine.setup(config)
	
end

function M.toggle()
	local mode = read_state() == "dark" and "light" or "dark"
	M.apply(mode)
	-- keep in sync with external script
	os.execute(string.format("echo %s > ~/.cache/theme-mode", mode))
end

-- Apply current mode on startup
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		M.apply(read_state())
	end,
})

-- Lualine refresh
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "background",
	callback = function()
		local mode = vim.o.background

		local theme = mode == "dark"
			and require("config.lualine_custom_gruvbox_dark")
			or require("config.lualine_custom_gruvbox_light")

		local lualine = require("lualine")
		local config = lualine.get_config()
		config.options.theme = theme
		lualine.setup(config)
	end,
})

return M
