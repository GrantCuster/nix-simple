return {
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },
		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("I", vim.lsp.buf.hover, "Hover Documentation")
				map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
				local builtin = require("telescope.builtin")
				map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
				map("grr", builtin.lsp_references, "[G]oto [R]eferences")
				map("gri", builtin.lsp_implementations, "[G]oto [I]mplementation")
				map("gO", builtin.lsp_document_symbols, "Open Document Symbols")
				map("gW", builtin.lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
				map("grt", builtin.lsp_type_definitions, "[G]oto [T]ype Definition")
			end,
		})

		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		-- Diagnostics keymap
		vim.keymap.set("n", "[e", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, { desc = "Go to previous diagnostic message" })

		vim.keymap.set("n", "]e", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, { desc = "Go to next diagnostic message" })

		vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		-- Installed through home-manager
		local lsps = { "ts_ls", "lua_ls", "nixd", "tailwindcss", "pyright", "marksman" }
		for _, lsp in ipairs(lsps) do
			vim.lsp.config(lsp, {
				capabilities = capabilities,
			})
			vim.lsp.enable(lsp)
		end
	end,
}
