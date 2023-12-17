vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	-- this colors in hexcodes and would do ANSI codes too if there weren't a buggy
	-- #FFFFFF will show up colored in if you do `:ColorHighlight`
	use({ "chrisbra/Colorizer" })
	-- I did this to play with the quickfix window, unsure if i care enough about it
	use({ "kevinhwang91/nvim-bqf", ft = "qf" })
	-- used to do GUI stuff
	use({ "MunifTanjim/nui.nvim" })
	-- used for autocompletion
	use({

		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			-- this makes it have completions for the built in vim shit the LSP can't see
			"hrsh7th/cmp-nvim-lua",
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-emoji",
			"dcampos/cmp-snippy",
			"dcampos/nvim-snippy",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			-- Setup nvim-cmp.
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local snippy = require("snippy")
			lspkind.init()

			-- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end
			-- `/` cmdline setup.
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			cmp.setup({
				snippet = {
					expand = function(args)
						snippy.expand_snippet(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif snippy.can_expand_or_advance() then
							snippy.expand_or_advance()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif snippy.can_jump(-1) then
							snippy.previous()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-e>"] = cmp.mapping.abort(),
					["<Esc>"] = cmp.mapping.close(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
				}),
				sources = cmp.config.sources({
					{ name = "path" }, -- for path completion
					{ name = "omni" },
					{ name = "snippy" },
					{ name = "emoji", insert = true }, -- emoji completion
					{ name = "codeium" },
					{ name = "nvim_lua" },
					{ name = "nvim_lsp" },
					{ name = "buffer" },
				}),
				completion = {
					keyword_length = 3,
					completeopt = "menu,menuone,noselect,noinsert",
				},
				view = {
					entries = "custom",
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						menu = {
							nvim_lsp = "[LSP]",
							snippy = "[Snippy]",
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
	-- complete UX overhaul, basically
	use({
		"folke/noice.nvim",
		requires = {
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("noice").setup({
				commands = {
					msg = {
						view = "split",
						opts = { enter = true, format = "details" },
						filter = {
							any = {
								{ event = "notify" },
								{
									event = "msg_show",
									["not"] = {
										kind = { "search_count", "" },
									},
								},
							},
						},
						filter_opts = { reverse = true },
					},
				},
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
				messages = {
					-- NOTE: If you enable messages, then the cmdline is enabled automatically.
					-- This is a current Neovim limitation.
					view = "mini", -- default view for messages
					view_error = "mini", -- view for errors
					view_warn = "mini", -- view for warnings
					view_history = "messages", -- view for :messages
					view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
				},
				views = {
					mini = {
						timeout = 10000,
					},
				},
				-- notify is too big and opaque and interferes with reading the actual code
				notify = {
					enabled = false,
				},
			})
		end,
	})
	-- really cool theme
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
	-- guess
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
	-- highlighting upgrade
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
	-- fzf
	use({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	-- makes it easier to navigate git projects
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

	-- theoretically, per-project config. haven't played with it
	use({
		"folke/neoconf.nvim",
	})
	require("neoconf").setup()
	use({
		-- I think this was supposed to be a dependency? FIXME!
		{
			"williamboman/mason.nvim",
		},
		-- the lsp magic
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
				-- TODO: are these still useful with nvim-cmp on?
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
	-- Moar fzf
	use("junegunn/fzf")
	-- MOAR fzf
	use("junegunn/fzf.vim")
	-- I haven't actually used this, it looks hella cool
	use("nvim-telescope/telescope-file-browser.nvim")
	-- Not sure why this has to be here, it's a library of neovim functions FIXME
	use("nvim-lua/plenary.nvim")
	-- sigh
	use("hashivim/vim-terraform")
	-- Git stuff that I probably don't use
	use("tpope/vim-fugitive")
	-- Git stuff that I do use
	use("airblade/vim-gitgutter")
	use({
		"ellisonleao/glow.nvim",
		config = function()
			require("glow").setup()
		end,
	})
	-- better rendering of markdown, doesn't deal with the injections nonsense in ts
	use("preservim/vim-markdown")
	-- Awesome linter plugin, fills in gaps in the LSP
	use("dense-analysis/ale")
	-- use 'ms-jpq/coq_nvim'
	-- Codeium
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
end)
