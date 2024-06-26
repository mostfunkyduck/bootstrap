vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
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
				lspconfig.jsonls.setup({})
				lspconfig.csharp_ls.setup({})
				lspconfig.terraformls.setup({
					filetypes = { "terraform", "tf", "terraform-vars" },
				})
				lspconfig.pyright.setup({})
				lspconfig.bashls.setup({})
				lspconfig.gdscript.setup({})
				lspconfig.lua_ls.setup({})
				lspconfig.rust_analyzer.setup({
					settings = {
						["rust-analyzer"] = {},
					},
				})
				lspconfig.gdscript.setup({})

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
	use({
		"nvim-lualine/lualine.nvim",

		requires = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("lualine").setup({
				sections = {
					lualine_a = { "mode" },
					lualine_b = {},
					lualine_c = {
						function()
							return require("nvim-treesitter").statusline({
								indicator_size = 100,
								type_patterns = { "class", "function", "method" },
								separator = " -> ",
							})
						end,
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				winbar = {
					lualine_a = {},
					lualine_b = {
						{ "buffers", mode = 4 },
						"branch",
						"diff",
						{ "diagnostics", sources = { "nvim_lsp", "nvim_diagnostic", "ale" } },
					},
					lualine_c = {
						{ "filename", path = 4 },
						"filetype",
					},
					lualine_x = { { "windows", mode = 2 }, "encoding", "searchcount", "selectioncount" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {},
			})
		end,
	})
	use({
		"lewis6991/gitsigns.nvim",
		requires = { "folke/which-key.nvim" },
		config = function()
			require("gitsigns").setup({
				auto_attach = true,
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")
					local wk = require("which-key")

					wk.register({ ["<leader>h"] = { name = "+gitsigns" } })
					local function map(mode, l, r, opts, wk_desc)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
						if wk_desc or "" ~= "" then
							wk.register({
								[l] = {
									[r] = wk_desc,
								},
								{
									mode = mode,
								},
							})
						end
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end, {}, "next hunk")

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end, {}, "previous hunk")

					-- Actions

					map("n", "<leader>hs", gitsigns.stage_hunk, {}, "stage hunk")
					map("n", "<leader>hr", gitsigns.reset_hunk, {}, "reset hunk")
					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, {}, "stage hunk")
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, {}, "reset hunk")
					map("n", "<leader>hS", gitsigns.stage_buffer, {}, "stage buffer")
					map("n", "<leader>hu", gitsigns.undo_stage_hunk, {}, "undo stage hunk")
					map("n", "<leader>hR", gitsigns.reset_buffer, {}, "reset buffer")
					map("n", "<leader>hp", gitsigns.preview_hunk, {}, "preview hunk")
					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end, {}, "blame line")
					map("n", "<leader>ht", gitsigns.toggle_current_line_blame, {}, "toggle current line blame")
					map("n", "<leader>hd", gitsigns.diffthis, {}, "diff this")
					map("n", "<leader>hl", gitsigns.toggle_linehl, {}, "toggle linehl")
					map("n", "<leader>hn", gitsigns.toggle_numhl, {}, "toggle numhl")
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end, {}, "diff against last commit")
					map("n", "<leader>htd", gitsigns.toggle_deleted, {}, "toggle deleted")

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", {}, "select hunk")
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
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-buffer",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-cmdline",
			"f3fora/cmp-spell",
		},
		config = function()
			-- Setup nvim-cmp.
			local cmp = require("cmp")

			-- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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
								vim.api.nvim_replace_termcodes("<C-U>", true, true, true) .. expanded,
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
				mapping = cmp.mapping.preset.insert({

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
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
				}, {
					{ name = "nvim_lua" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lsp" },
				}, { -- this is the stuff that's less interesting
					{ name = "emoji", insert = true }, -- emoji completion
					{ name = "omni" },
					{ name = "nvim_lsp_document_symbol" },
					{
						name = "buffer",
						option = {
							keyword_pattern = [[\k\+]],
						},
					},
				}),
				completion = {
					keyword_length = 3,
					completeopt = "menu,menuone,noselect,noinsert",
				},
				view = {
					entries = {
						name = "custom",
					},
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = false, -- turn this off, it makes things annoying when i don't want what's in the auto-completion
				},
			})
			vim.opt.spell = true
			vim.opt.spelllang = { "en_us" }
			cmp.setup.filetype("markdown", {
				sources = cmp.config.sources({
					{
						name = "spell",
					},
				}),
			})
		end,
	})
	use({
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({
				render = "compact",
				stages = "static",
				timeout = 10000,
				top_down = false,
			})
		end,
	})
	-- complete UX overhaul, basically
	use({
		"folke/noice.nvim",
		requires = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
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
					enabled = false, -- enables the Noice messages UI
					view = nil,
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
				style = "storm",
				transparent = true,
			})
			vim.cmd([[colorscheme tokyonight-storm]])
		end,
	})
	-- guess
	use({
		"jackMort/ChatGPT.nvim",
		config = function()
			require("chatgpt").setup({
				openai_edit_params = {
					model = "gpt-4o",
					frequency_penalty = 0,
					presence_penalty = 0,
					temperature = 0,
					top_p = 1,
					n = 1,
				},
				--[[
        -- How I enabled Gemini Pro (Google AI Studio)
				api_key_cmd = "cat " .. vim.fn.expand("$HOME") .. "/.gemini/api-key",
				api_host_cmd = "echo -n http://127.0.0.1:4000",
        ]]
				api_key_cmd = "bash " .. vim.fn.expand("$HOME") .. "/.config/nvim/scripts/get_openai_key.sh",
				predefined_chat_gpt_prompts = "file://"
					.. vim.fn.expand("$HOME")
					.. "/.config/nvim/chatgpt-prompts.csv",
			})
		end,
		requires = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
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
					"markdown_inline",
					"regex",
				},
				-- they say this is experimental
				indent = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<leader>gnn",
						node_incremental = "<leader>grn",
						scope_incremental = "<leader>grc",
						node_decremental = "<leader>grm",
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
		requires = { { "nvim-lua/plenary.nvim", "folke/which-key.nvim" } },
		config = function()
			local telescope = require("telescope")
			local wk = require("which-key")
			telescope.setup({
				defaults = {
					file_ignore_patterns = { ".git/" },
				},
			})
			local builtin = require("telescope.builtin")
			wk.register({
				["<leader>t"] = {
					name = "telescope",
					n = { telescope.extensions.notify.notify, "telescope notify extension" },
					f = {
						name = "file browser and find",
						f = {
							function()
								require("telescope.builtin").find_files({
									follow = true,
									hidden = true,
								})
							end,
							"telescope ff, follow and hidden",
						},
						z = { builtin.current_buffer_fuzzy_find, "telescope current buffer fuzzy find" },
					},
					g = { builtin.live_grep, "telescope live grep" },
					b = { builtin.buffers, "telescope buffers" },
					h = { builtin.help_tags, "telescope help tags" },
					p = { "<CMD>Telescope projects<CR>", "telescope projects" },
				},
				["<leader>tfb"] = {
					telescope.extensions.file_browser.file_browser,
					"telescope file browser",
				},
			})
		end,
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
	-- Moar fzf
	use("junegunn/fzf")
	-- MOAR fzf
	use("junegunn/fzf.vim")
	use("nvim-telescope/telescope-file-browser.nvim")
	-- Not sure why this has to be here, it's a library of neovim functions FIXME
	use("nvim-lua/plenary.nvim")
	use({
		"ellisonleao/glow.nvim",
		config = function()
			require("glow").setup()
		end,
	})
	-- Awesome linter plugin, fills in gaps in the LSP
	use("dense-analysis/ale")
end)
