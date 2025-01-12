vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<esc>", { noremap = true })
vim.keymap.set("t", "jk", [[<C-\><C-n>]])

-- vim.keymap.set("n", "tt", ":pu=strftime('%c')<CR>o<CR><esc>", { noremap = true })

-- up/down wrapped lines
vim.keymap.set("n", "<down>", "gj", { noremap = true })
vim.keymap.set("n", "<up>", "gk", { noremap = true })
vim.keymap.set("v", "<down>", "gj", { noremap = true })
vim.keymap.set("v", "<up>", "gk", { noremap = true })

vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("v", "j", "gj", { noremap = true })
vim.keymap.set("v", "k", "gk", { noremap = true })

vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { noremap = true })
vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { noremap = true })
vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { noremap = true })
vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { noremap = true })
vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { noremap = true })
vim.keymap.set("t", "<C-.>", [[clear<CR>]], { noremap = true })
vim.keymap.set({ "n", "t" }, "<C-w>", [[<Cmd>q<CR>]], { noremap = true, nowait = true })
vim.keymap.set({ "n", "t" }, "<C-->", [[<Cmd>Oil<CR>]], { noremap = true })
vim.keymap.set({ "n", "t" }, "<C-q>", ":qa<CR>", {})
vim.keymap.set("n", "<C-s>", ":w<CR>", {})
-- reload base
vim.keymap.set("n", "<leader>rb", ":luafile ~/.config/nvim/lua/base.lua<CR>", {})

vim.keymap.set({ "n" }, "<C-i>", "<C-d>", { noremap = true })

vim.keymap.set({ "n", "t" }, "<C-e>", [[<Cmd>split<CR><Cmd>wincmd j<CR><Cmd>Oil<CR>]], {})
vim.keymap.set({ "n", "t" }, "<C-d>", [[<Cmd>vsplit<CR><Cmd>wincmd l<CR><Cmd>Oil<CR>]], {})

vim.keymap.set({ "n", "t" }, "<C-g>", [[<Cmd>LazyGit<CR>]], {})

vim.api.nvim_command("autocmd VimResized * wincmd =")
vim.keymap.set("n", "<leader>=", [[<Cmd>wincmd =<CR>]], {})

vim.opt.showmode = false

vim.keymap.set("n", "<C-enter>", function()
	local vim_dir = vim.fn.expand("%:p:h")
	vim_dir = vim_dir:gsub("^oil://", "")
	vim.fn.setenv("VIM_DIR", vim_dir)
	vim.cmd("terminal")
	vim.schedule(function()
		vim.fn.chansend(vim.b.terminal_job_id, "cd " .. vim_dir .. " && clear\n")
	end)
end, { noremap = true })
-- vim.keymap.set("n", "<enter>", ":term", {})
-- vim.keymap.set("t", "<enter>", "i", {})

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	group = vim.api.nvim_create_augroup("terminal-switch", { clear = true }),
-- 	pattern = "term://*",
-- 	callback = function()
-- 		-- Your custom logic here
-- 		-- Example: Change to insert mode when entering a terminal
-- 		vim.cmd("startinsert")
-- 		vim.opt.number = false
-- 		vim.opt.relativenumber = false
-- 		vim.opt.spell = false
--
-- 		print("Switched to terminal!")
-- 	end,
-- })

vim.keymap.set("n", "<leader>ev", ":e ~/.config/nvim/init.lua<cr>", { noremap = true })
vim.keymap.set("n", "<leader>en", ":e ~/nix/home/home.nix<cr>", { noremap = true })

vim.opt.scrolloff = 9999
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.equalalways = false

vim.opt.spelllang = "en_us"
vim.opt.spell = true

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set("n", "<leader>n", ":set number!<CR>:set relativenumber!<CR>", {})
-- vim.cmd("autocmd filetype markdown setlocal nonumber")
-- vim.cmd("autocmd filetype markdown setlocal norelativenumber")

-- copy all text in the buffer
vim.keymap.set("n", "<leader>aa", "ggVGy", {})

-- neoclip
vim.keymap.set("n", "<leader>cc", ":Telescope neoclip<CR>", {})

vim.filetype.add({
	pattern = { [".*/hyprland%.conf"] = "hyprlang" },
})

vim.cmd("set ignorecase")
vim.keymap.set("n", "<escape>", ":noh<CR>")

-- jump back to previous
vim.keymap.set("n", "<leader>bb", ":edit #<CR>")

vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#1d2021" })

-- highlight yanked text for 200ms using the "Visual" highlight group
vim.cmd([[
augroup highlight_yank
autocmd!
au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=200})
augroup END
]])

vim.keymap.set("n", "<leader>w", ":wa<CR>", {})
vim.keymap.set("n", "<leader>q", ":qa<CR>", {})

-- task item for obsidian
vim.keymap.set("n", "<leader>tc", "o- [ ] ")

vim.keymap.set("n", "J", ":move .+1<CR>==")
vim.keymap.set("n", "K", ":move .-2<CR>==")
vim.keymap.set("v", "J", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":move '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader><enter>", function()
	local winwidth = vim.fn.winwidth(0) * 0.5
	local winheight = vim.fn.winheight(0)
	if winwidth > winheight then
		return "<CMD>vsplit<CR><CMD>wincmd l<CR>"
	else
		return "<CMD>split<CR><CMD>wincmd j<CR>"
	end
end, { expr = true, replace_keycodes = true })

vim.keymap.set({ "n", "t" }, "<C-t>", function()
	local winwidth = vim.fn.winwidth(0) * 0.5
	local winheight = vim.fn.winheight(0)
	if winwidth > winheight then
		return "<CMD>vsplit<CR><CMD>wincmd l<CR><CMD>term<CR>"
	else
		return "<CMD>split<CR><CMD>wincmd j<CR><CMD>term<CR>"
	end
end, { expr = true, replace_keycodes = true })

-- jump to next diagnostic error
vim.keymap.set("n", "]e", ":lua vim.diagnostic.goto_next()<CR>")
-- jump to previous diagnostic error
vim.keymap.set("n", "[e", ":lua vim.diagnostic.goto_prev()<CR>")

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Create an autocmd group
local group_id = vim.api.nvim_create_augroup("ToggleLineNumbers", { clear = true })

-- Turn off line numbers when entering a terminal
vim.api.nvim_create_autocmd("BufEnter", {
	group = group_id,
	pattern = "term://*",
	callback = function()
		vim.opt.spell = false
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.cmd("startinsert")
	end,
})
vim.api.nvim_create_autocmd("TermOpen", {
	group = group_id,
	pattern = "term://*",
	callback = function()
		vim.opt.spell = false
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.cmd("startinsert")
	end,
})

-- Turn on line numbers when entering a regular file buffer
vim.api.nvim_create_autocmd("BufEnter", {
	group = group_id,
	pattern = "*",
	callback = function()
		if not vim.bo.buftype == "terminal" then
			vim.opt.spell = true
			vim.opt.number = true
			vim.opt.relativenumber = true
		end
	end,
})

vim.keymap.set({ "n" }, "<C-c>", function()
	-- Get the current line
	local current_line = vim.fn.getline(".")
	-- Get the current line number
	local line_number = vim.fn.line(".")
	if current_line:find("%- %[ %]") then
		local new_line = current_line:gsub("%- %[ %]", "- [x]")
		vim.fn.setline(line_number, new_line)
	elseif current_line:find("%- %[x%]") then
		local new_line = current_line:gsub("%- %[x%] ", "")
		vim.fn.setline(line_number, new_line)
	else
		vim.fn.setline(line_number, "- [ ] " .. current_line)
	end
end, { desc = "Toggle task done or not" })

-- Create an autocmd group for image handling
vim.api.nvim_create_augroup("ImageBuffers", { clear = true })

-- Add an autocmd to detect opening of .jpg, .jpeg, and .png files
vim.api.nvim_create_autocmd("BufReadPost", {
	group = "ImageBuffers",
	pattern = "*.jpg,*.jpeg,*.png,*.gif,*.avif,*.webp",
	callback = function()
		-- Get the full path of the file
		local filepath = vim.fn.expand("%:p")
		-- Run the viu command and capture its output
		local viu_output = vim.fn.system("viu --blocks --static " .. vim.fn.shellescape(filepath))
		-- Remove carriage return characters (^M)
		viu_output = viu_output:gsub("\r", "")
		local baleia = require("baleia").setup({})
		baleia.buf_set_lines(0, 0, -1, true, vim.split(viu_output, "\n", { plain = true }))
		-- Mark the buffer as unmodifiable and unlisted
		vim.bo.modifiable = false
		vim.bo.buflisted = false
		-- Turn off line numbers
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})
