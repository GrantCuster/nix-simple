local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

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
			require("telescope").setup({
				defaults = {
					layout_strategy = "flex",
					layout_config = {
						width = 0.9,
						height = 0.9,
					},
				},
				-- mappings = {
				-- 	n = {
				-- 		["<c-x>"] = require("telescope.actions").delete_buffer,
				-- 	},
				-- 	i = {
				-- 		["<c-x"] = require("telescope.actions").delete_buffer,
				-- 	},
				-- },
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader><Space>", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fd", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {})
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
				-- should update to main branch
				-- getting stuck on compiling - debug later
				-- ensure_installed = { "javascript", "html", "vim", "vimdoc", "markdown", "markdown_inline" },
				ensure_installed = {},
				sync_install = false,
				auto_install = true,
				ignore_install = {},
				modules = {},
				highlight = { enable = true },
				indent = { enable = true },
				folds = { enable = true },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({})
			lspconfig.ts_ls.setup({})
			lspconfig.nixd.setup({})
			lspconfig.tailwindcss.setup({})
			lspconfig.pyright.setup({})
			lspconfig.marksman.setup({})
			lspconfig.gleam.setup({})

			vim.keymap.set("n", "I", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
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

			-- cmp.setup.filetype("markdown", {
			--   sources = cmp.config.sources({}),
			-- })

			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("lspconfig")["lua_ls"].setup({ capabilities = capabilities })
			require("lspconfig")["ts_ls"].setup({ capabilities = capabilities })
			require("lspconfig")["tailwindcss"].setup({ capabilities = capabilities })
			require("lspconfig")["pyright"].setup({ capabilities = capabilities })
			require("lspconfig")["nixd"].setup({ capabilities = capabilities })
			require("lspconfig")["marksman"].setup({ capabilities = capabilities })
			require("lspconfig")["gleam"].setup({ capabilities = capabilities })
		end,
	},
	{
		"numToStr/Comment.nvim",
	},
	-- {
	-- 	"github/copilot.vim",
	-- },
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			"zbirenbaum/copilot-cmp",
		},
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<Tab>",
						accept_word = false,
						accept_line = false,
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
				panel = { enabled = false },
				copilot_node_command = "node",
			})

			-- Enable Copilot LSP
			vim.lsp.enable("copilot")
		end,
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
	{ "christoomey/vim-tmux-navigator" },
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
				},
				filetypes = { "oil" },
			}
			require("lualine").setup({
				options = {
					icons_enabled = false,
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
					draw_empty = false,
					globalstatus = true,
					theme = require("config/lualine_custom_gruvbox"),
				},
				-- lualine_a = {
				-- 	{
				-- 		cwd,
				-- 		padding = { left = 0, right = 1 },
				-- 	},
				-- },
				sections = {
					lualine_a = { "branch", "diff" },
					lualine_b = { { "filename", path = 4 } },
					lualine_c = {},
					lualine_x = {},
					lualine_y = { "filetype" },
					lualine_z = { { "mode", padding = { left = 1, right = 0 } } },
				},
				tabline = {
					lualine_a = {
						{
							cwd,
							padding = { left = 0, right = 0 },
						},
					},
				},
			})
			-- transparent status
			vim.api.nvim_set_hl(0, "StatusLine", { bg = "none", fg = "none" })
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		opts = {
			-- Your configuration, if any
		},
    -- stylua: ignore
    keys = {
      -- opencode.nvim exposes a general, flexible API — customize it to your workflow!
      -- But here are some examples to get you started :)
      { '<leader>oo', function() require('opencode').toggle() end,                                               desc = 'Toggle opencode',                 { mode = { 'n', 'v', 't' } }, },
      { '<leader>oa', function() require('opencode').ask() end,                                                  desc = 'Ask opencode',                    mode = { 'n', 'v' }, },
      { '<leader>oA', function() require('opencode').ask('@file ') end,                                          desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
      { '<leader>on', function() require('opencode').command('/new') end,                                        desc = 'New session', },
      { '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end,              desc = 'Explain code near cursor' },
      { '<leader>or', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
      { '<leader>of', function() require('opencode').prompt('Fix these @diagnostics') end,                       desc = 'Fix errors', },
      -- { '<leader>oo', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection',              mode = 'v', },
      { '<leader>od', function() require('opencode').prompt('Add documentation comments for @selection') end,    desc = 'Document selection',              mode = 'v', },
    },
	},
	{
		"echasnovski/mini.nvim",
		version = "*",
		config = function()
			require("mini.ai").setup()
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		config = function()
			require("codecompanion").setup({
				adapters = {
					openai = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = "cmd:cat ~/nix/openai_api_key",
							},
						})
					end,
				},
				strategies = {
					chat = {
						adapter = "openai",
					},
				},
				display = {
					chat = {
						window = {
							layout = "buffer",
						},
					},
				},
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"sindrets/diffview.nvim",
	},
	{
		"folke/sidekick.nvim",
		opts = {
			-- add any options here
			cli = {
				mux = {
					enabled = false,
				},
			},
		},
		keys = {
			{
				"<tab>",
				function()
					-- if there is a next edit, jump to it, otherwise apply it if any
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>" -- fallback to normal tab
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
			},
			{
				"<c-.>",
				function()
					require("sidekick.cli").focus()
				end,
				desc = "Sidekick Switch Focus",
				mode = { "n", "v" },
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle({ focus = true })
				end,
				desc = "Sidekick Toggle CLI",
				mode = { "n", "v" },
			},
			{
				"<leader>ac",
				function()
					require("sidekick.cli").toggle({ name = "claude", focus = true })
				end,
				desc = "Sidekick Claude Toggle",
				mode = { "n", "v" },
			},
			{
				"<leader>ag",
				function()
					require("sidekick.cli").toggle({ name = "grok", focus = true })
				end,
				desc = "Sidekick Grok Toggle",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				function()
					require("sidekick.cli").select_prompt()
				end,
				desc = "Sidekick Ask Prompt",
				mode = { "n", "v" },
			},
		},
	},
})
