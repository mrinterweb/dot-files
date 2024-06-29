-- Basic settings
vim.opt.compatible = false
vim.opt.backspace = "indent,eol,start"
vim.opt.history = 50
vim.opt.ruler = true
vim.opt.showcmd = true
vim.opt.incsearch = true
vim.opt.linebreak = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.backupdir = vim.fn.expand("~/.vim/backup//")
vim.opt.directory = vim.fn.expand("~/.vim/swap//")
vim.opt.undodir = vim.fn.expand("~/.vim/undo//")
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.laststatus = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- Key mappings
vim.g.mapleader = " "

vim.keymap.set('i', 'jj', '<Esc>')
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('i', 'kk', '<Esc>:w<CR>')

-- Plugin management with lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Color scheme
  {
    "bluz71/vim-moonfly-colors",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme moonfly]])
    end,
  },

  -- Git integration
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",

  -- Ruby and Rails
  "tpope/vim-rails",
  "vim-ruby/vim-ruby",

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup()
      telescope.load_extension("fzf")

      vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>')
      vim.keymap.set('n', '<C-g>', '<cmd>Telescope live_grep<cr>')
      vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
      vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
      vim.keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>')
      vim.keymap.set('n', '<leader>fd', '<cmd>Telescope lsp_definitions<cr>')
    end
  },

  -- Snippets
  {
    "SirVer/ultisnips",
    dependencies = { "honza/vim-snippets" },
    config = function()
      vim.g.UltiSnipsExpandTrigger = "<C-s>"
      vim.g.UltiSnipsSnippetsDir = vim.fn.expand("~/.vim/UltiSnips")
      vim.g.UltiSnipsEditSplit = "vertical"
    end
  },

  -- Utility plugins
  "majutsushi/tagbar",
  "preservim/nerdcommenter",
  "terryma/vim-multiple-cursors",
  "tpope/vim-endwise",
  "tpope/vim-surround",

  -- Testing
  {
    "vim-test/vim-test",
    config = function()
      vim.g['test#strategy'] = {
        nearest = 'neovim',
        file = 'neovim',
        suite = 'dispatch_background'
      }
      vim.g['test#ruby#rspec#executable'] = 'spring rspec --fail-fast=3'
      vim.g['test#ruby#rspec#options'] = {
        nearest = '--format documentation',
        file = '--format documentation'
      }

      vim.keymap.set('n', 't<C-n>', ':w<CR>:TestNearest<CR>')
      vim.keymap.set('n', 't<C-f>', ':w<CR>:TestFile<CR>')
      vim.keymap.set('n', 't<C-l>', ':w<CR>:TestLast<CR>')
      vim.keymap.set('n', 't<C-s>', ':TestSuite<CR>')
      vim.keymap.set('n', 't<C-g>', ':TestVisit<CR>')
    end
  },
  "tpope/vim-dispatch",

  -- UI enhancements
  "Valloric/ListToggle",
  {
    "itchyny/lightline.vim",
    config = function()
      vim.g.lightline = {
        colorscheme = 'powerline',
        active = {
          left = { { 'mode', 'paste' }, { 'readonly', 'filename', 'modified' } },
          right = { { 'lineinfo' }, { 'percent' }, { 'filetype' } }
        }
      }
    end
  },

  -- LSP and completion
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()

      local lspconfig = require("lspconfig")
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local servers = { 'solargraph', 'tsserver' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'ultisnips' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "ruby", "javascript", "json", "yaml", "regex", "css", "scss", "html", "markdown", "vim", "lua"  },
        highlight = {
          enable = true,
        },
      })
    end
  },

  -- File explorer
  {
    "preservim/nerdtree",
    config = function()
      vim.keymap.set('n', '<Leader>n', ':NERDTreeToggle<CR>')
      vim.keymap.set('n', '<Leader>b', ':NERDTreeFind<CR>')
    end
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  -- Git integration
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua",              -- optional
    },
    config = true,
    keys = {
      {
        "<leader>gg",
        "<cmd>Neogit<cr>",
        noremap = true,
        silent = true,
        desc = "Open Neogit"
      },
    },
  },

  -- Motion
  {
    "ggandor/leap.nvim",
    config = function()
      require('leap').add_default_mappings()
    end
  },

  -- GitHub Copilot
  "github/copilot.vim",

  -- dev icons
  'nvim-tree/nvim-web-devicons',

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        ruby = { "standardrb" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set("n", "<leader>ll", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          svelte = { { "prettierd", "prettier" } },
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          javascriptreact = { { "prettierd", "prettier" } },
          typescriptreact = { { "prettierd", "prettier" } },
          json = { { "prettierd", "prettier" } },
          graphql = { { "prettierd", "prettier" } },
          java = { "google-java-format" },
          kotlin = { "ktlint" },
          ruby = { "standardrb" },
          markdown = { { "prettierd", "prettier" } },
          erb = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          bash = { "beautysh" },
          proto = { "buf" },
          rust = { "rustfmt" },
          yaml = { "yamlfix" },
          toml = { "taplo" },
          css = { { "prettierd", "prettier" } },
          scss = { { "prettierd", "prettier" } },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>l", function()
        require('conform').format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 2000,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  }
})

-- Additional configurations

-- Autocommands
vim.cmd([[
  augroup vimrc_augroup
    autocmd!
    autocmd BufWritePost .vimrc source $MYVIMRC
    autocmd BufWritePre * %s/\s\+$//e
    autocmd FileType vue syntax sync fromstart
    autocmd InsertEnter * :set number
    autocmd InsertLeave * :set relativenumber
  augroup END
]])

-- Custom functions
vim.cmd([[
  function! RipgrepFzf(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
  endfunction

  command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
]])

vim.keymap.set('n', '<Leader>gp', ':RG<cr>')

-- Additional key mappings
vim.keymap.set('n', '<Leader>mt', ':tabnew<CR>')
vim.keymap.set('n', '<Leader>tn', ':tabnext<CR>')
vim.keymap.set('n', '<Leader>tp', ':tabprevious<CR>')
vim.keymap.set('n', '<Leader>r', ':tabdo set relativenumber!<CR>')
vim.keymap.set('x', '<Leader>c', '"*y<Esc>')
vim.keymap.set('n', '<Leader>gs', ':Git<CR>')
vim.keymap.set('n', '<Leader>h', ':set invhls<CR>')
vim.keymap.set('n', '<Leader>e', ':e <C-R>=expand("%:p:h") . "/" <CR>')
vim.keymap.set('n', '<Leader>te', ':tabe <C-R>=expand("%:p:h") . "/" <CR>')
vim.keymap.set('n', '<Leader>]', ':tabnext<CR>')
vim.keymap.set('n', '<Leader>[', ':tabprevious<CR>')

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

vim.keymap.set('n', '<Leader>ww', ':q<CR>')

-- Copy and past
vim.keymap.set('v', '<Leader>Y', '"*y')

-- Set Python paths
if vim.fn.filereadable('/usr/local/bin/python') == 1 then
  vim.g.python_host_prog = '/usr/local/bin/python'
elseif vim.fn.filereadable('/opt/homebrew/bin/python') == 1 then
  vim.g.python_host_prog = '/opt/homebrew/bin/python'
elseif vim.fn.filereadable('/usr/bin/python') == 1 then
  vim.g.python_host_prog = '/usr/bin/python'
else
  print('No python2 found')
end

if vim.fn.filereadable('/usr/local/bin/python3') == 1 then
  vim.g.python3_host_prog = '/usr/local/bin/python3'
elseif vim.fn.filereadable('/opt/homebrew/bin/python3') == 1 then
  vim.g.python3_host_prog = '/opt/homebrew/bin/python3'
elseif vim.fn.filereadable('/usr/bin/python') == 1 then
  vim.g.python3_host_prog = '/usr/bin/python'
else
  print("No python3 found")
end

-- Custom functions
-- Function to save the session
function SaveSession()
  local last_session_path = vim.fn.expand('~/.vim/last_session.vim')
  if vim.fn.filereadable(last_session_path) == 1 then
    vim.cmd('mksession! ' .. last_session_path)
    print('Session saved to: ' .. last_session_path)
  else
    print('Session path not readable: ' .. last_session_path)
    vim.fn.system('touch ' .. last_session_path)
    print('File should be created now. Try running this again')
  end
end

-- Function to load the session
function LoadSession()
  local last_session_path = vim.fn.expand('~/.vim/last_session.vim')
  if vim.fn.filereadable(last_session_path) == 1 then
    vim.cmd('source ' .. last_session_path)
    print('Session loaded from: ' .. last_session_path)
  else
    print('Session path not readable: ' .. last_session_path)
  end
end

-- Create user commands for these functions
vim.api.nvim_create_user_command('SaveSession', SaveSession, {})
vim.api.nvim_create_user_command('LoadSession', LoadSession, {})
