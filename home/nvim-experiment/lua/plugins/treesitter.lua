return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local wanted = {
      "diff", "lua", "bash", "nix",
      "javascript", "typescript",
      "python", "rust", "markdown",
    }

    local installed = require("nvim-treesitter.config").get_installed()
    local to_install = vim.tbl_filter(function(lang)
      return not vim.list_contains(installed, lang)
    end, wanted)

    if #to_install > 0 then
      require("nvim-treesitter").install(to_install)
    end

    -- Enable treesitter highlighting for every buffer
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
