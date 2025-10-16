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
		filetypes =
			{ "oil" }, require("lualine").setup({
				options = {
					icons_enabled = false,
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
					draw_empty = false,
					globalstatus = true,
					theme = "gruvbox",
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
					lualine_b = {
						{
							cwd,
							padding = { left = 0, right = 1 },
						},
					},
				},
			})
		-- transparent status
		-- vim.api.nvim_set_hl(0, "StatusLine", { bg = "none", fg = "none" })
	end,
}
