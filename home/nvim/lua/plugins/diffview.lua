return {
  'sindrets/diffview.nvim',
  config = function()
    vim.keymap.set('n', '<leader>dd', function() require('diffview').open() end, { desc = "New changes" })
  end,
}
