return {
	"github/copilot.vim",
  enabled = false,
  init = function()
    vim.g.copilot_filetypes = {vibe = false, markdown = false}
  end,
}
