vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        manual_mode = false,
        show_hidden = true,
        detection_methods = { "pattern" },
      }
    end
  }

  use {
      {
          "williamboman/mason.nvim",
      },
      {
          "neovim/nvim-lspconfig",
          config = function()
              local lspconfig = require("lspconfig")
              lspconfig.terraformls.setup {}
          end
      }
  }
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'
  use 'nvim-telescope/telescope-file-browser.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'hashivim/vim-terraform'
  use 'tpope/vim-fugitive'
  use 'airblade/vim-gitgutter'
  use 'ellisonleao/glow.nvim'
  use 'dense-analysis/ale'
  -- use 'ms-jpq/coq_nvim'
  -- use 'Exafunction/codeium.vim'
  -- this may be broken
  use 'vim-scripts/AnsiEsc.vim'
end)
