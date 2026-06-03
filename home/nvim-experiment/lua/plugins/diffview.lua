return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("diffview").setup({
      view = {
        default = {
          layout = "diff2_vertical",
        },
        merge_tool = {
          layout = "diff3_vertical",
        },
      },
      panel = {
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
    })
  end,
}
