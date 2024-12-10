local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<esc>", { noremap = true })

vim.keymap.set("n", "tt", ":pu=strftime('%c')<CR>o<CR><esc>", { noremap = true })

-- up/down wrapped lines
vim.keymap.set("n", "<down>", "gj", { noremap = true })
vim.keymap.set("n", "<up>", "gk", { noremap = true })
vim.keymap.set("v", "<down>", "gj", { noremap = true })
vim.keymap.set("v", "<up>", "gk", { noremap = true })

vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("v", "j", "gj", { noremap = true })
vim.keymap.set("v", "k", "gk", { noremap = true })

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

vim.cmd("set number")
vim.cmd("set relativenumber")
vim.keymap.set("n", "<leader>n", ":set number!<CR>", {})
vim.cmd("autocmd filetype markdown setlocal nonumber")
vim.cmd("autocmd filetype markdown setlocal norelativenumber")

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
vim.keymap.set("n", "<leader>q", ":q<CR>", {})

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
		return ":vsplit<CR><C-W>l"
	else
		return ":split<CR><C-W>j"
	end
end, { expr = true, replace_keycodes = true })

-- jump to next diagnostic error
vim.keymap.set("n", "]e", ":lua vim.diagnostic.goto_next()<CR>")
-- jump to previous diagnostic error
vim.keymap.set("n", "[e", ":lua vim.diagnostic.goto_prev()<CR>")

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("lazy").setup({
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				bold = false,
				italic = {
					strings = false,
					emphasis = false,
					comments = false,
					operators = false,
					folds = false,
				},
				invert_selection = true,
				transparent_mode = true,
			})
			vim.o.background = "dark"
			vim.cmd([[colorscheme gruvbox]])
			vim.api.nvim_set_hl(0, "Todo", { bg = "none" })
			vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#282828" })
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader><Space>", builtin.find_files, {})
			vim.keymap.set("n", "<leader>lg", builtin.live_grep, {})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = { "lua", "javascript", "html", "vim", "vimdoc", "markdown", "markdown_inline" },
				sync_install = false,
				auto_install = true,
				ignore_install = {},
				modules = {},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local function cwd()
				local full_path = vim.loop.cwd()
				return full_path:match("([^/]+)$") -- Extract the last part of the string after "/"
			end
			local custom_oil = {
				sections = {
					lualine_a = {
						function()
							local ok, oil = pcall(require, "oil")
							if ok then
								return vim.fn.fnamemodify(oil.get_current_dir(), ":~")
							else
								return ""
							end
						end,
					},
					lualine_b = { "branch" },
					lualine_z = { cwd },
				},
				filetypes = { "oil" },
			}
			require("lualine").setup({
				options = {
					theme = "gruvbox",
					icons_enabled = true,
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { cwd, "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				extensions = { custom_oil },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({})
			lspconfig.tsserver.setup({})
			lspconfig.nixd.setup({})
			lspconfig.tailwindcss.setup({})
			lspconfig.pyright.setup({})

			vim.keymap.set("n", "I", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
	{ "christoomey/vim-tmux-navigator" },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			cmp.setup.filetype("markdown", {
				sources = cmp.config.sources({}),
			})

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("lspconfig")["lua_ls"].setup({ capabilities = capabilities })
			require("lspconfig")["tsserver"].setup({ capabilities = capabilities })
			require("lspconfig")["tailwindcss"].setup({ capabilities = capabilities })
			require("lspconfig")["pyright"].setup({ capabilities = capabilities })
			require("lspconfig")["nixd"].setup({ capabilities = capabilities })
		end,
	},
	{ "folke/neodev.nvim", opts = {} },
	-- {
	--   "epwalsh/obsidian.nvim",
	--   version = "*",
	--   ft = "markdown",
	--   dependencies = {
	--     "nvim-lua/plenary.nvim",
	--   },
	--   opts = {
	--     workspaces = {
	--       {
	--         name = "personal",
	--         path = "~/obsidian",
	--       },
	--     },
	--     daily_notes = {
	--       folder = "daily",
	--     },
	--     completion = {
	--       min_chars = 0,
	--     },
	--     ui = {
	--       hl_groups = {
	--         ObsidianTodo = { bold = true, fg = "#7c6f64" },
	--         ObsidianDone = { bold = true, fg = "#98971a" },
	--       },
	--     },
	--   },
	-- },
	-- {
	--   "opdavies/toggle-checkbox.nvim",
	--   config = function()
	--     vim.keymap.set("n", "<leader>tt", ":lua require('toggle-checkbox').toggle()<CR>")
	--   end,
	-- },
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
		lazy = false,
	},
	-- {
	--   "luckasRanarison/tree-sitter-hyprlang",
	--   dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- },
	{
		"github/copilot.vim",
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettierd,
				},
			})
			vim.keymap.set("n", "<leader>ff", ":lua vim.lsp.buf.format()<CR>")
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics open focus=true<cr>",
			},
			{
				"<leader>xz",
				"<cmd>Trouble diagnostics close<cr>",
			},
		},
	},
	{
		"stevearc/oil.nvim",
		opts = {
			default_file_explorer = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = {
					"actions.select",
					opts = { vertical = true },
					desc = "Open the entry in a vertical split",
				},
				-- ["<C-h>"] = {
				--   "actions.select",
				--   opts = { horizontal = true },
				--   desc = "Open the entry in a horizontal split",
				-- },
				["<C-h>"] = false,
				["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
				["<C-p>"] = "actions.preview",
				-- ["<C-c>"] = "actions.close",
				["<C-c>"] = false,
				["q"] = "actions.close",
				-- ["<C-l>"] = "actions.refresh",
				["<C-l>"] = false,
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
		},
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	-- {
	--   "ThePrimeagen/harpoon",
	--   branch = "harpoon2",
	--   dependencies = { "nvim-lua/plenary.nvim" },
	--   config = function()
	--     local harpoon = require("harpoon")
	--     harpoon.setup()
	--     vim.keymap.set("n", "<leader>ha", function()
	--       harpoon:list():add()
	--     end)
	--     vim.keymap.set("n", "<leader>hh", function()
	--       harpoon.ui:toggle_quick_menu(harpoon:list())
	--     end)
	--     vim.keymap.set("n", "<leader>1", function()
	--       harpoon:list():select(1)
	--     end)
	--     vim.keymap.set("n", "<leader>2", function()
	--       harpoon:list():select(2)
	--     end)
	--     vim.keymap.set("n", "<leader>3", function()
	--       harpoon:list():select(3)
	--     end)
	--     vim.keymap.set("n", "<leader>4", function()
	--       harpoon:list():select(4)
	--     end)
	--   end,
	-- },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			dashboard = { enabled = true },
			indent = { enabled = false },
			input = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			zen = { enabled = true },
		},
	},
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
			{ "kkharji/sqlite.lua", module = "sqlite" },
		},
		config = function()
			require("neoclip").setup({
				continuous_sync = true,
			})
		end,
	},
})
