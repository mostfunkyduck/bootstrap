vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				auto_attach = true,
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end)

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end)

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk)
					map("n", "<leader>hr", gitsigns.reset_hunk)
					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gitsigns.stage_buffer)
					map("n", "<leader>hu", gitsigns.undo_stage_hunk)
					map("n", "<leader>hR", gitsigns.reset_buffer)
					map("n", "<leader>hp", gitsigns.preview_hunk)
					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>hd", gitsigns.diffthis)
					map("n", "<leader>hl", gitsigns.toggle_linehl)
					map("n", "<leader>hn", gitsigns.toggle_numhl)
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end)
					map("n", "<leader>td", gitsigns.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	})
	use("eandrju/cellular-automaton.nvim")
	use("habamax/vim-godot")
	use("wbthomason/packer.nvim")
	-- mapping hints
	use({
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
			require("which-key").setup()
		end,
	})
	-- this colors in hexcodes and would do ANSI codes too if there weren't a buggler
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
			-- this makes it have completions for the built in vim shit the LSP can't see
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"onsails/lspkind-nvim",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-emoji",
			"dcampos/cmp-snippy",
			"dcampos/nvim-snippy",
			"hrsh7th/nvim-cmp",
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
				    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") ==
				    nil
			end
			-- https://github.com/hrsh7th/cmp-cmdline/issues/33#issuecomment-1793891721
			local function handle_tab_complete(direction)
				return function()
					if vim.api.nvim_get_mode().mode == "c" and cmp.get_selected_entry() == nil then
						local text = vim.fn.getcmdline()
						---@diagnostic disable-next-line: param-type-mismatch
						local expanded = vim.fn.expandcmd(text)
						if expanded ~= text then
							vim.api.nvim_feedkeys(
								vim.api.nvim_replace_termcodes("<C-U>", true, true, true) ..
								expanded,
								"n",
								false
							)
							cmp.complete()
						elseif cmp.visible() then
							direction()
						else
							cmp.complete()
						end
					else
						if cmp.visible() then
							direction()
						else
							cmp.complete()
						end
					end
				end
			end
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline({
					["<Tab>"] = { c = handle_tab_complete(cmp.select_next_item) },
					["<S-Tab>"] = { c = handle_tab_complete(cmp.select_prev_item) },
				}),

				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline_history" },
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
					["<CR>"] = cmp.mapping.confirm({ select = false }),
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
					{ name = "emoji",                  insert = true }, -- emoji completion
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lua" },
					{ name = "nvim_lsp" },
					{ name = "codeium" },
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
				messages = {
					-- NOTE: If you enable messages, then the cmdline is enabled automatically.
					-- This is a current Neovim limitation.
					enabled = true, -- enables the Noice messages UI
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
				-- notify is too big and opaque and interferes with reading the actual code
				notify = {
					enabled = true,
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
				api_key_cmd = "bash " ..
				vim.fn.expand("$HOME") .. "/.config/nvim/scripts/get_openai_key.sh",
				predefined_chat_gpt_prompts = "file://"
				    .. vim.fn.expand("$HOME")
				    .. "/.config/nvim/chatgpt-prompts.csv",
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
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				sync_install = true,
				auto_install = true,
				ensure_installed = {
					"python",
					"rust",
					"vim",
					"typescript",
					"javascript",
					"terraform",
					"bash",
					"yaml",
					"lua",
				},
				-- they say this is experimental
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
			vim.cmd([[
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
" keeps it from folding everything at startup
set nofoldenable
]])
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
				lspconfig.tsserver.setup({})
				lspconfig.gopls.setup({})
				lspconfig.csharp_ls.setup({})
				lspconfig.terraformls.setup({
					filetypes = { "terraform", "tf", "terraform-vars" },
				})
				lspconfig.pyright.setup({})
				lspconfig.bashls.setup({})
				lspconfig.gdscript.setup({})
				lspconfig.lua_ls.setup({})
				lspconfig.groovyls.setup({
					cmd = {
						"/opt/homebrew/opt/openjdk@17/bin/java",
						"-jar",
						"/Users/Jack.Kuperman/code/groovy-language-server/build/libs/groovy-language-server-all.jar",
					},
				})
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
				vim.keymap.set("n", "<space>qf", vim.diagnostic.setqflist)

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
						vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder,
							opts)
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
	-- Git stuff that I probably don't use
	use("tpope/vim-fugitive")
	-- Git stuff that I do use
	--use("airblade/vim-gitgutter")
	use({
		"ellisonleao/glow.nvim",
		config = function()
			require("glow").setup()
		end,
	})
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
