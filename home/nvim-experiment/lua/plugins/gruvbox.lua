return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      bold = false,
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
      invert_selection = true,
    })
    vim.o.background = "dark"
    vim.cmd("colorscheme gruvbox")

    -- Subtle diff backgrounds so syntax highlighting stays readable
    local function set_diff_highlights()
      vim.api.nvim_set_hl(0, "DiffAdd",    { bg = "#1e3220" })
      vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#3b1c1c" })
      vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2e2a16" })
      vim.api.nvim_set_hl(0, "DiffText",   { bg = "#4a3f10", bold = true })
    end
    set_diff_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_diff_highlights })
  end,
}
