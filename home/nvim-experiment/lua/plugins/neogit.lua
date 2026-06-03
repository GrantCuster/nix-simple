return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "NeogitCommitView", "NeogitLogView" },
      callback = function()
        vim.schedule(function()
          vim.cmd("resize " .. math.floor(vim.o.lines * 0.7))
        end)
      end,
    })

    require("neogit").setup({
      graph_style = "unicode",
      treesitter_diff_highlight = true,
      integrations = {
        diffview = true,
      },
      commit_view = {
        kind = "split",
      },
      log_view = {
        kind = "split",
      },
    })
  end,
}
