local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
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
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader><Space>", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
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
      require("lspconfig")["ts_ls"].setup({ capabilities = capabilities })
      require("lspconfig")["tailwindcss"].setup({ capabilities = capabilities })
      require("lspconfig")["pyright"].setup({ capabilities = capabilities })
      require("lspconfig")["nixd"].setup({ capabilities = capabilities })
    end,
  },
  { "folke/neodev.nvim",             opts = {} },
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
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
      { "kkharji/sqlite.lua",           module = "sqlite" },
    },
    config = function()
      require("neoclip").setup({
        continuous_sync = true,
      })
    end,
  },
  {
    "m00qek/baleia.nvim",
    version = "*",
    config = function()
      vim.g.baleia = require("baleia").setup({})

      -- Command to colorize the current buffer
      vim.api.nvim_create_user_command("BaleiaColorize", function()
        vim.g.baleia.once(vim.api.nvim_get_current_buf())
      end, { bang = true })

      -- Command to show logs
      vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
    end,
  },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
  {
    "https://github.com/nocksock/do.nvim",
    config = function()
      require("do").setup({
        -- default options
        kaomoji_mode = 1, -- 0 kaomoji everywhere, 1 skip kaomoji in doing
        winbar = false,
        doing_prefix = "",
        store = {
          auto_create_file = false, -- automatically create a .do_tasks when calling :Do
          file_name = ".do_tasks",
        },
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
      local function first_unchecked_task()
        local filepath = vim.fn.expand("~/dev/TODO.md")
        local file = io.open(filepath, "r")
        if file then
          for line in file:lines() do
            local task = line:match("^%- %[ %] (.+)")
            if task then
              file:close()
              return task
            end
          end
          file:close()
          return "No unchecked tasks"
        end
        return "File not found"
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
          theme = "gruvbox",
          icons_enabled = false,
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
          draw_empty = false,
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename" } },
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "filetype" },
        },
        tabline = {
          lualine_a = { cwd },
          lualine_b = {
            first_unchecked_task,
          },
        },
      })
    end,
  },
})
