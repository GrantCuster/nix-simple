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

-- for obsidian plugin
vim.opt.conceallevel = 1

vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<esc>", { noremap = true })

vim.opt.scrolloff = 9999
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.opt.equalalways = false

vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.cmd("set number")
vim.cmd("set relativenumber")
vim.keymap.set("n", "<leader>n", ":set number!<CR>", {})
vim.cmd("autocmd filetype markdown setlocal nonumber")
vim.cmd("autocmd filetype markdown setlocal norelativenumber")

vim.filetype.add({
  pattern = { [".*/hyprland%.conf"] = "hyprlang" },
})

vim.cmd("set ignorecase")
vim.keymap.set("n", "<escape>", ":noh<CR>")

vim.keymap.set("n", "<leader>bb", ":edit #<CR>")

vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#1d2021" })

-- highlight yanked text for 200ms using the "Visual" highlight group
vim.cmd([[
augroup highlight_yank
autocmd!
au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=200})
augroup END
]])

vim.keymap.set("n", "<leader>s", ":w<CR>", {})
vim.keymap.set("n", "<leader>w", ":q<CR>", {})

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
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader><Space>", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
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
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
          },
          hijack_netrw_behavior = "open_current",
        },
        window = {
          width = 32,
        },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree filesystem reveal left toggle<CR>", {})
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",
          icons_enabled = false,
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
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
      require("lspconfig")["nixd"].setup({ capabilities = capabilities })
      require("lspconfig")["tailwindcss"].setup({ capabilities = capabilities })
    end,
  },
  { "folke/neodev.nvim",             opts = {} },
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/obsidian",
        },
      },
      daily_notes = {
        folder = "daily",
      },
      completion = {
        min_chars = 0,
      },
      ui = {
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#7c6f64" },
          ObsidianDone = { bold = true, fg = "#98971a" },
        },
      },
    },
  },
  {
    "opdavies/toggle-checkbox.nvim",
    config = function()
      vim.keymap.set("n", "<leader>tt", ":lua require('toggle-checkbox').toggle()<CR>")
    end,
  },
  {
    "numToStr/Comment.nvim",
    opts = {
      -- add any options here
    },
    lazy = false,
  },
  {
    "luckasRanarison/tree-sitter-hyprlang",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
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
})
