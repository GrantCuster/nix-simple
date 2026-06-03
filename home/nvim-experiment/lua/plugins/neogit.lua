return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("neogit").setup({
      graph_style = "unicode",
      integrations = {
        diffview = true,
      },
    })
  end,
}
