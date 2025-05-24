-- LEADER and ESCAPE
vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<esc>", { noremap = true })
vim.keymap.set("t", "jk", [[<C-\><C-n>]])

-- LINE NAVIGATION
vim.keymap.set("n", "<down>", "gj", { noremap = true })
vim.keymap.set("n", "<up>", "gk", { noremap = true })
vim.keymap.set("v", "<down>", "gj", { noremap = true })
vim.keymap.set("v", "<up>", "gk", { noremap = true })
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("v", "j", "gj", { noremap = true })
vim.keymap.set("v", "k", "gk", { noremap = true })

-- CONTROL KEYBINDINGS
-- usually for things I want to do across modes (normal, terminal, insert)

-- terminal match
vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { noremap = true })
vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { noremap = true })
vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { noremap = true })
vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { noremap = true })

-- terminal clear
vim.keymap.set("t", "<C-.>", [[clear<CR>]], { noremap = true })

-- Open oil - match - in normal
vim.keymap.set({ "n", "t", "i" }, "<C-->", function()
	local cwd = vim.fn.getcwd()
	vim.cmd("edit " .. cwd)
end, { noremap = true })

-- Close window - handle codecompanion special
local function quit_or_toggle()
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	if buftype == "codecompanion" then
		vim.cmd("CodeCompanion Toggle")
	else
		vim.cmd("q")
	end
end
vim.keymap.set({ "n", "t", "i" }, "<C-w>", quit_or_toggle, { noremap = true, nowait = true })

-- Save
vim.keymap.set({ "n", "i" }, "<C-s>", ":wa<CR>", {})

-- Reload base config
vim.keymap.set("n", "<leader>rb", ":luafile ~/.config/nvim/lua/base.lua<CR>", {})
vim.keymap.set("n", "<leader>rs", ":luafile ~/.config/nvim/lua/config/luasnip.lua<CR>", {})

-- Copy current path
vim.keymap.set("n", "<leader>cf", ":let @+ = expand('%')<CR>", {})

vim.keymap.set({ "n" }, "<C-i>", "<C-d>", { noremap = true })

-- Fold current
vim.keymap.set("n", "zz", "za", { noremap = true })

vim.keymap.set({ "n", "t" }, "<C-e>", function()
	vim.cmd("split")
	vim.cmd("wincmd j")
	local buf_ft = vim.bo.filetype
	if vim.bo[0].buftype == "terminal" then
		local cwd = vim.fn.getcwd()
		vim.cmd("terminal fish -C 'cd " .. cwd .. "'")
	elseif buf_ft ~= "oil" then
		-- vim.cmd("Oil")
	end
end, {})
vim.keymap.set({ "n", "t" }, "<C-d>", function()
	vim.cmd("vsplit")
	vim.cmd("wincmd l")
	local buf_ft = vim.bo.filetype
	if vim.bo[0].buftype == "terminal" then
		local cwd = vim.fn.getcwd()
		vim.cmd("terminal fish -C 'cd " .. cwd .. "'")
	elseif buf_ft ~= "oil" then
		-- vim.cmd("Oil")
	end
end, {})

vim.o.foldenable = true -- Enable folding by default
vim.o.foldmethod = "expr" -- Set foldmethod to "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()" -- Set foldexpr to use treesitter
vim.o.foldlevelstart = 99 -- Start with all folds open
vim.o.foldnestmax = 3 -- Maximum nested folds
vim.o.foldminlines = 1

vim.keymap.set({ "n", "t" }, "<C-g>", [[<Cmd>LazyGit<CR>]], {})

vim.api.nvim_command("autocmd VimResized * wincmd =")
vim.keymap.set("n", "<leader>=", [[<Cmd>wincmd =<CR>]], {})

vim.opt.showmode = false

vim.opt.splitright = true

vim.opt.fillchars:append({ eob = " " })

-- Auto reload files
vim.o.updatetime = 1000
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

vim.keymap.set("n", "<C-enter>", function()
	local vim_dir = vim.fn.expand("%:p:h")
	vim_dir = vim_dir:gsub("^oil://", "")
	vim_dir = vim_dir:gsub("/v:null", "")
	vim.cmd("terminal fish -C 'cd " .. vim_dir .. "'")
end, { noremap = true })

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

vim.keymap.set("n", "<leader>ev", ":e ~/.config/nvim/base.lua<cr>", { noremap = true })
vim.keymap.set("n", "<leader>en", ":e ~/nix/home/home.nix<cr>", { noremap = true })

vim.opt.scrolloff = 9999
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.equalalways = false

-- vim.opt.spelllang = "en_us"
-- vim.opt.spell = true

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set("n", "<leader>n", ":set number!<CR>:set relativenumber!<CR>", {})
vim.keymap.set(
	"n",
	"<leader>m",
	":set nonumber<CR>:set norelativenumber<CR>:set nospell<CR>:set signcolumn=no<CR>:set laststatus=0<CR>:set noruler<CR>:set noshowcmd<CR>:echo ''<CR>",
	{}
)

-- copy all text in the buffer
vim.keymap.set("n", "<leader>aa", "ggVGy", {})

-- neoclip
vim.keymap.set("n", "<leader>cc", ":Telescope neoclip<CR>", {})

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
-- vim.keymap.set("n", "<leader>q", ":qa<CR>", {})

vim.keymap.set("n", "J", ":move .+1<CR>==")
vim.keymap.set("n", "K", ":move .-2<CR>==")
vim.keymap.set("v", "J", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":move '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader><enter>", function()
	local winwidth = vim.fn.winwidth(0) * 0.5
	local winheight = vim.fn.winheight(0)
	local buf_ft = vim.bo.filetype
	if winwidth > winheight then
		vim.cmd("vsplit")
		vim.cmd("wincmd l")
	else
		vim.cmd("split")
		vim.cmd("wincmd j")
	end
	if buf_ft == "terminal" then
		local cwd = vim.fn.getcwd()
		vim.cmd("terminal fish -C 'cd " .. cwd .. "'")
	elseif buf_ft ~= "oil" then
		vim.cmd("Oil")
	end
end, {})

local todo_win_id = nil -- Store the floating window ID

vim.keymap.set({ "n", "t" }, "<C-t>", function()
	-- Close the floating window if it exists
	if todo_win_id and vim.api.nvim_win_is_valid(todo_win_id) then
		vim.api.nvim_win_close(todo_win_id, true)
		todo_win_id = nil
		return
	end

	-- Set desired width and height
	local width = 90
	local height = 40

	-- Calculate centered position
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create a new scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Open the floating window
	todo_win_id = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.cmd("edit ~/dev/TODO.md") -- Open the file in the floating window
end, { noremap = true, silent = true })

local aero_win_id = nil -- Store the floating window ID

vim.keymap.set({ "n", "t" }, "<M-p>", function()
	-- Close the floating window if it exists
	if aero_win_id and vim.api.nvim_win_is_valid(aero_win_id) then
		vim.api.nvim_win_close(aero_win_id, true)
		aero_win_id = nil
		return
	end

	-- Get the line number from the shell command asynchronously
	local result = vim.fn.system("aerospace list-workspaces --focused")
	local line_number = tonumber(result:match("%d+")) or 1

	-- Set desired width and height
	local width = 90
	local height = 40

	-- Calculate centered position
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create a new scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Open the floating window
	aero_win_id = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- Open the file at the specified line
	vim.cmd("edit +" .. line_number .. " ~/dev/aerospace.txt")
end, { noremap = true, silent = true })
-- jump to next diagnostic error
vim.keymap.set("n", "]e", ":lua vim.diagnostic.goto_next()<CR>")
-- jump to previous diagnostic error
vim.keymap.set("n", "[e", ":lua vim.diagnostic.goto_prev()<CR>")
vim.keymap.set("n", "<leader>cd", ":lua vim.diagnostic.open_float()<CR>")

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.keymap.set({ "n", "i" }, "<C-c>", function()
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

vim.api.nvim_create_augroup("ImageBuffers", { clear = true })

vim.keymap.set({ "n", "v", "t" }, "<C-a>", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>cc", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.keymap.set("i", "<S-SPACE>", function()
	vim.fn.feedkeys(vim.fn["copilot#Accept"](), "n")
end, { desc = "Copilot accept" })

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local buf_ft = vim.bo.filetype -- Get the current buffer's filetype

		-- Skip if the buffer is a Telescope buffer
		if buf_ft == "TelescopePrompt" then
			return
		end

		-- Check if the buffer is a terminal
		if vim.bo.buftype == "terminal" then
			local bufname = vim.api.nvim_buf_get_name(0)
			local pwd = bufname:match("term://(.-)::")
			if pwd then
				vim.api.nvim_set_current_dir(pwd)
			end
		elseif buf_ft == "oil" then
			-- The buffer is an Oil buffer
			local oil = require("oil")
			local oil_path = oil.get_current_dir() -- Get the directory associated with the Oil buffer
			if oil_path then
				-- Check if this directory or its parents contain a .project or .git directory
				local project_dir = vim.fn.finddir(".project", oil_path .. ";")
				local git_dir = vim.fn.finddir(".git", oil_path .. ";")

				if project_dir ~= "" then
					local target_dir = vim.fn.fnamemodify(project_dir, ":h")
					vim.api.nvim_set_current_dir(target_dir)
				elseif git_dir ~= "" then
					local target_dir = vim.fn.fnamemodify(git_dir, ":h")
					vim.api.nvim_set_current_dir(target_dir)
				elseif oil_path ~= "v:null" then
					-- Default to Oil's path if neither .project nor .git is found
					-- vim.api.nvim_set_current_dir(oil_path)
				end
			end
		else
			-- Handle non-Oil buffers
			local project_dir = vim.fn.finddir(".project", ".;")
			local git_dir = vim.fn.finddir(".git", ".;")

			if project_dir ~= "" then
				local target_dir = vim.fn.fnamemodify(project_dir, ":h")
				vim.api.nvim_set_current_dir(target_dir)
			elseif git_dir ~= "" then
				local target_dir = vim.fn.fnamemodify(git_dir, ":h")
				vim.api.nvim_set_current_dir(target_dir)
			else
				-- Set the parent directory as the working directory if no .project or .git directory is found
				local bufname = vim.api.nvim_buf_get_name(0) -- Get the buffer's name (path)
				if bufname ~= "" then
					local parent_dir = vim.fn.fnamemodify(bufname, ":h")
					if parent_dir ~= "" then
						vim.api.nvim_set_current_dir(parent_dir)
					end
				end
			end
		end
	end,
})

vim.api.nvim_create_autocmd("BufRead", {
	pattern = "aerospace.txt", -- Change this to your specific file
	callback = function()
		vim.keymap.set("n", "<enter>", function() -- Get the current line content
			local line = vim.fn.getline(".")
			local first_word = line:match("^(%S+)") -- Extract the first word before space
			-- Run a shell command with the line as an argument
			vim.cmd("silent !aerospace workspace " .. vim.fn.shellescape(first_word))
		end, { buffer = true, noremap = true, silent = true })
	end,
})

-- Attempt to restore folds
local view_group = vim.api.nvim_create_augroup("auto_view", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
	desc = "Save view with mkview for real files",
	group = view_group,
	callback = function(args)
		if vim.b[args.buf].view_activated then
			vim.cmd.mkview({ mods = { emsg_silent = true } })
		end
	end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
	desc = "Try to load file view if available and enable view saving for real files",
	group = view_group,
	callback = function(args)
		if not vim.b[args.buf].view_activated then
			local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
			local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
			if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
				vim.b[args.buf].view_activated = true
				vim.cmd.loadview({ mods = { emsg_silent = true } })
			end
		end
	end,
})

function OpenFileInRightWindow()
	local file = vim.fn.expand("<cfile>") -- Get the file name under the cursor
	if file == "" then
		print("No file detected under cursor")
		return
	end

	local current_win = vim.api.nvim_get_current_win()
	local current_pos = vim.api.nvim_win_get_position(current_win)
	local curr_col, curr_row = current_pos[2], current_pos[1] -- X (col), Y (row)
	local windows = vim.api.nvim_tabpage_list_wins(0)

	local closest_right_win = nil
	local min_y_diff = math.huge -- Keep track of the closest window in Y direction

	for _, win in ipairs(windows) do
		local pos = vim.api.nvim_win_get_position(win)
		local win_row, win_col = pos[1], pos[2]

		if win_col > curr_col then -- Ensure the window is to the right
			local y_diff = math.abs(win_row - curr_row)
			if y_diff < min_y_diff then
				min_y_diff = y_diff
				closest_right_win = win
			end
		end
	end

	if closest_right_win then
		-- Open the file in the closest right window
		vim.api.nvim_set_current_win(closest_right_win)
		vim.cmd("edit " .. vim.fn.fnameescape(file))
		-- Switch back to the original window
		vim.api.nvim_set_current_win(current_win)
	else
		-- No right window exists, open in a new vertical split
		vim.cmd("vsplit " .. vim.fn.fnameescape(file))
		-- Switch back to the original window
		-- vim.api.nvim_set_current_win(current_win)
	end
end

-- Map the function to a key (e.g., <leader>gf)
vim.api.nvim_set_keymap("n", "ge", ":lua OpenFileInRightWindow()<CR>", { noremap = true, silent = true })

local function get_terminal_buffers()
	local terminal_buffers = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
			table.insert(terminal_buffers, buf)
		end
	end
	return terminal_buffers
end

-- Function to toggle through terminal buffers
function Toggle_terminal_buffers()
	local terminal_buffers = get_terminal_buffers()
	if #terminal_buffers == 0 then
		print("No terminal buffers open")
		return
	end

	local current_buf = vim.api.nvim_get_current_buf()
	for i, buf in ipairs(terminal_buffers) do
		if buf == current_buf then
			local next_buf = terminal_buffers[(i % #terminal_buffers) + 1]
			vim.api.nvim_set_current_buf(next_buf)
			return
		end
	end

	-- If current buffer is not a terminal, switch to the first terminal buffer
	vim.api.nvim_set_current_buf(terminal_buffers[1])
end

vim.keymap.set({ "n", "t" }, "<C-t>", "<Cmd>lua Toggle_terminal_buffers()<CR>", { noremap = true, silent = true })

vim.opt.fillchars:append { diff = "╱" }

vim.keymap.set("n", "<leader>gg", function()
  if next(require("diffview.lib").views) == nil then
    vim.cmd("DiffviewOpen")
  else
    vim.cmd("DiffviewClose")
  end
end)

vim.keymap.set("n", "<leader>gh", function()
  if next(require("diffview.lib").views) == nil then
    vim.cmd("DiffviewFileHistory")
  else
    vim.cmd("DiffviewClose")
  end
end)

vim.keymap.set("n", "<leader>gf", function()
  if next(require("diffview.lib").views) == nil then
    vim.cmd("DiffviewFileHistory %")
  else
    vim.cmd("DiffviewClose")
  end
end)

vim.api.nvim_create_user_command("Gsync", function()
	vim.cmd("!git add . && git commit -am 'update' && git pull origin main --rebase && git push origin main")
end, {})
vim.keymap.set("n", "<leader>gs", ":Gsync<CR>", { noremap = true, silent = true })


