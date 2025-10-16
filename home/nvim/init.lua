require("core.options")
require("core.keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end

-- not lazy
require("plugins.theme")

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)
require("lazy").setup({
  require("plugins.gruvbox"),
  require("plugins.guess-indent"),
  require("plugins.gitsigns"),
  require("plugins.oil"),
  require("plugins.telescope"),
  require("plugins.treesitter"),
  require("plugins.autocompletion"),
  require("plugins.lsp-config"),
  require("plugins.lua-for-neovim"),
  require("plugins.autoformat"),
  require("plugins.todo-comments"),
  require("plugins.mini"),
  require("plugins.comment"),
  require("plugins.lualine"),
  require("plugins.copilot"),
  -- require("plugins.ai-sidekick")
})
