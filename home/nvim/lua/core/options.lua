vim.o.number = true
vim.o.relativenumber = true

vim.g.have_nerd_font = true

vim.o.mouse = 'a'

vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- vim.o.cursorline = true

vim.o.scrolloff = 999
vim.opt.swapfile = false

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- donot show tabline
vim.o.showtabline = 0

-- set shell
vim.opt.shell = "/home/grant/.nix-profile/bin/fish"

-- Keep splits even
vim.api.nvim_command("autocmd VimResized * wincmd =")
vim.keymap.set("n", "<leader>=", [[<Cmd>wincmd =<CR>]], {})

-- Auto-reload files when changed outside of Neovim
vim.o.autoread = true
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	callback = function()
		vim.cmd("checktime")
	end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function()
		vim.cmd("checktime")
	end,
})
vim.api.nvim_create_autocmd("FocusGained", {
	pattern = "*",
	callback = function()
		vim.cmd("checktime")
	end,
})

vim.deprecate = function ()
  -- Disable
end

vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
	pattern = "term://*",
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.cmd("startinsert")
	end,
})

-- terminal styling
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	callback = function()
		if vim.bo[0].buftype == "terminal" then
			vim.opt.number = false
			vim.opt.relativenumber = false
			vim.cmd("startinsert")
		else
			if vim.bo[0].filetype == "oil" then
				vim.opt.number = true
				vim.opt.relativenumber = true
			else
				vim.opt.number = true
				vim.opt.relativenumber = true
			end
		end
	end,
})


