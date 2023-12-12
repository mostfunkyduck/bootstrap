vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use({ "kevinhwang91/nvim-bqf", ft = "qf" })
	use({
		"rcarriga/nvim-notify",
	}, { "MunifTanjim/nui.nvim" })
	use({
		"folke/noice.nvim",
		config = function()
			require("noice").setup({
				lsp = {
					-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				-- you can enable a preset for easier configuration
				presets = {
					bottom_search = true, -- use a classic bottom cmdline for search
					command_palette = true, -- position the cmdline and popupmenu together
					long_message_to_split = true, -- long messages will be sent to a split
					inc_rename = false, -- enables an input dialog for inc-rename.nvim
					lsp_doc_border = false, -- add a border to hover docs and signature help
				},
				hover = {
					silent = false,
				},
			})
		end,
	})
	use({
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				style = "night",
				transparent = true,
			})
			vim.cmd([[colorscheme tokyonight]])
		end,
	})
	use({
		"jackMort/ChatGPT.nvim",
		config = function()
			require("chatgpt").setup({
				api_key_cmd = "bash " .. vim.fn.expand("$HOME") .. "/.config/nvim/scripts/get_openai_key.sh",
			})
		end,
		requires = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
	})
	use("wbthomason/packer.nvim")
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
		config = function()
			return require("nvim-treesitter").setup({
				auto_install = true,
			})
		end,
	})
	use({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				manual_mode = false,
				show_hidden = true,
				detection_methods = { "pattern" },
			})
		end,
	})

	use({
		"folke/neoconf.nvim",
	})
	require("neoconf").setup()
	use({
		{
			"williamboman/mason.nvim",
		},
		{
			"neovim/nvim-lspconfig",
			config = function()
				local lspconfig = require("lspconfig")
				lspconfig.csharp_ls.setup({})
				lspconfig.terraformls.setup({})
				lspconfig.pyright.setup({})
				lspconfig.lua_ls.setup({})
				lspconfig.rust_analyzer.setup({
					settings = {
						["rust-analyzer"] = {},
					},
				})

				-- Global mappings.
				-- See `:help vim.diagnostic.*` for documentation on any of the below functions
				vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
				vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

				-- Use LspAttach autocommand to only map the following keys
				-- after the language server attaches to the current buffer
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("UserLspConfig", {}),
					callback = function(ev)
						-- Enable completion triggered by <c-x><c-o>
						vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

						-- Buffer local mappings.
						-- See `:help vim.lsp.*` for documentation on any of the below functions
						local opts = { buffer = ev.buf }
						vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
						vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
						vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
						vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
						vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
						vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
						vim.keymap.set("n", "<space>wl", function()
							print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
						end, opts)
						vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
						vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
						vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
						vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
						vim.keymap.set("n", "<space>f", function()
							vim.lsp.buf.format({ async = true })
						end, opts)
					end,
				})
			end,
		},
	})
	use("junegunn/fzf")
	use("junegunn/fzf.vim")
	use("nvim-telescope/telescope-file-browser.nvim")
	use("nvim-lua/plenary.nvim")
	use("hashivim/vim-terraform")
	use("tpope/vim-fugitive")
	use("airblade/vim-gitgutter")
	use("ellisonleao/glow.nvim")
	use("dense-analysis/ale")
	-- use 'ms-jpq/coq_nvim'
	use({

		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-emoji",
			"quangnguyen30192/cmp-nvim-ultisnips",
		},
		config = function()
			-- Setup nvim-cmp.
			local cmp = require("cmp")
			local lspkind = require("lspkind")

			cmp.setup({
				snippet = {
					expand = function(args)
						-- For `ultisnips` user.
						vim.fn["UltiSnips#Anon"](args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-e>"] = cmp.mapping.abort(),
					["<Esc>"] = cmp.mapping.close(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
				}),
				sources = {
					{ name = "nvim_lsp" }, -- For nvim-lsp
					{ name = "ultisnips" }, -- For ultisnips user.
					{ name = "path" }, -- for path completion
					{ name = "buffer", keyword_length = 2 }, -- for buffer word completion
					{ name = "emoji", insert = true }, -- emoji completion
					{ name = "codeium" },
				},
				completion = {
					keyword_length = 1,
					completeopt = "menu,noselect",
				},
				view = {
					entries = "custom",
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						menu = {
							nvim_lsp = "[LSP]",
							ultisnips = "[US]",
							nvim_lua = "[Lua]",
							path = "[Path]",
							buffer = "[Buffer]",
							emoji = "[Emoji]",
							omni = "[Omni]",
							codeium = "[Codeium]",
						},
					}),
				},
			})
		end,
	})
	use({
		"Exafunction/codeium.nvim",
		-- "/home/jack/code/github/mostfunkyduck/codeium.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"onsails/lspkind-nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})
		end,
	})
	-- use("/home/jack/code/github/mostfunkyduck/codeium.nvim")
	-- this may be broken
	use("vim-scripts/AnsiEsc.vim")
end)
