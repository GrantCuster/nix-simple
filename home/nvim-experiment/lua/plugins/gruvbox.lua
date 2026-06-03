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
  end,
}
