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
	if mode == "light" then
		vim.o.background = "light"
		vim.cmd([[colorscheme gruvbox]])
	else
		vim.o.background = "dark"
		vim.cmd([[colorscheme gruvbox]])
	end

	-- ✅ Force Lualine to reload theme after colorscheme change
	local ok, lualine = pcall(require, "lualine")
	if ok then
		lualine.setup({})
	end
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

return M
