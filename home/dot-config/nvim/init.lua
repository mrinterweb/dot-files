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

vim.o.winborder = 'rounded'

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
  --{
    --"bluz71/vim-moonfly-colors",
    --lazy = false,
    --priority = 1000,
    --config = function()
      --vim.cmd([[colorscheme moonfly]])
    --end,
  --},
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme kanagawa]])
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
      "nvim-telescope/telescope-live-grep-args.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      'LukasPietzschmann/telescope-tabs',
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        pickers = {
          buffers = {
            mappings = {
              i = {
                ["<c-d>"] = "select_tab_drop", -- Map Enter to select_tab_drop
              },
            },
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")

      vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>')
      --vim.keymap.set('n', '<C-g>', '<cmd>Telescope live_grep<cr>')
      vim.keymap.set('n', '<C-g>', require("telescope").extensions.live_grep_args.live_grep_args)
      vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
      vim.keymap.set('n', '<leader>;', '<cmd>Telescope buffers<cr>')
      vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
      vim.keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>')
      vim.keymap.set('n', '<leader>fd', '<cmd>Telescope lsp_definitions<cr>')
      vim.keymap.set('n', '<leader>f ', '<cmd>Telescope resume<cr>')
      vim.keymap.set('n', '<leader>\'', '<cmd>Telescope telescope-tabs list_tabs<cr>')
    end
  },

  --{
    --'LukasPietzschmann/telescope-tabs',
    --config = function()
      --require('telescope').load_extension 'telescope-tabs'
      --require('telescope-tabs').setup {
        ---- Your custom config :^)
      --}
    --end,
    --dependencies = { 'nvim-telescope/telescope.nvim' },
  --},

  -- Utility plugins
  "majutsushi/tagbar",
  -- "preservim/nerdcommenter",
  "terryma/vim-multiple-cursors",
  "tpope/vim-endwise",
  "tpope/vim-surround",

  {
    'numToStr/Comment.nvim',
    opts = {
      mappings = {
        basic = true,
      }
    }
  },

  -- Testing
  {
    "vim-test/vim-test",
    config = function()
      vim.g['test#strategy'] = {
        nearest = 'neovim',
        file = 'neovim',
        suite = 'dispatch_background'
      }
      --vim.g['test#ruby#rspec#executable'] = 'spring rspec --fail-fast=3'
      vim.g['test#ruby#rspec#executable'] = 'bundle exec rspec --fail-fast=3'
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
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    config = true,
  },

  -- Your existing LSP configuration with Mason check
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local lspconfig = require('lspconfig')

      -- Ruby LSP configuration (using ASDF)
      lspconfig.ruby_lsp.setup({
        cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
        init_options = {
          formatter = 'standard',
          linters = { 'standard' },
          addonSettings = {
            ["Ruby LSP Rails"] = {
              enablePendingMigrationsPrompt = false,
            },
          },
        },
      })

      -- TypeScript/JavaScript LSP configuration
      -- Check if typescript-language-server is installed via Mason
      local ts_ls_cmd = vim.fn.exepath("typescript-language-server")
      if ts_ls_cmd ~= "" then
        lspconfig.ts_ls.setup({
          cmd = { ts_ls_cmd, "--stdio" },
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        })
      else
        -- Fallback to system installation
        lspconfig.ts_ls.setup({
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        })
      end

      -- Add other LSP servers as needed
      -- You can manually install them via :Mason and configure them here
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

  {
    'saghen/blink.cmp',
    dependencies = {
      'Kaiser-Yang/blink-cmp-avante',
    },
    -- optional: provides snippets for the snippet source
    -- dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = 'default' },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              -- options for blink-cmp-avante
            }
          }
        },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" }
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
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
    config = function()
      -- This is found in the lua directory
      require 'neogit_config'
    end,
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

  -- https://github.com/mrloop/telescope-git-branch.nvim
  -- { 'mrloop/telescope-git-branch.nvim' },

  -- Motion
  {
    "ggandor/leap.nvim",
    config = function()
      require('leap').add_default_mappings()
    end
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    lazy = false, -- Or however you manage loading
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_node_command = "/Users/sean/.asdf/shims/node"
      vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
      })
    end,
  },

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
        ruby = { "rubocop" },
        sql = { "sqlfluff" },
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
    opts = {
      linters = {
        sqlfluff = {
          args = {
            "lint",
            "--dialect=postgres",
          },
        },
      },
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          svelte = { "prettierd", "prettier" },
          javascript = { "prettierd", "prettier" },
          typescript = { "prettierd", "prettier" },
          javascriptreact = { "prettierd", "prettier" },
          typescriptreact = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          graphql = { "prettierd", "prettier" },
          java = { "google-java-format" },
          kotlin = { "ktlint" },
          ruby = { "standardrb" },
          markdown = { "prettierd", "prettier" },
          erb = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          bash = { "beautysh" },
          proto = { "buf" },
          rust = { "rustfmt" },
          yaml = { "yamlfix" },
          toml = { "taplo" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
        },
      })

      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = true })
      end, { desc = 'Format buffer' })
      -- vim.keymap.set({ "n", "v" }, "<leader>l", function()
      --   require('conform').format({
      --     lsp_fallback = true,
      --     async = false,
      --     timeout_ms = 2000,
      --   })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup {
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
      }
    end,
  },
})

-- LSP attach configuration
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- Enable completion
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end

    -- Enable hover
    if client.server_capabilities.hoverProvider then
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP Hover" })
    end
  end,
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

vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })

vim.keymap.set("n", "<Leader>cf", function()
  local filepath = vim.fn.expand("%")
  vim.fn.setreg("+", filepath)
end, { desc = "Copy relative path to clipboard" })
-- Copy to system clipboard
-- Does not work because the terminal does not pass this through
-- vim.keymap.set('v', '<D-c>', '"+y<Esc>', { desc = 'Copy to clipboard' })
-- Paste from system clipboard
vim.keymap.set({'n', 'i'}, '<D-v>', '<C-r>+', { desc = 'Paste from clipboard' })
-- Cut to system clipboard
vim.keymap.set('v', '<D-x>', '"+x', { desc = 'Cut to clipboard' })
-- Select all
vim.keymap.set('n', '<D-a>', 'ggVG', { desc = 'Select all' })
-- Save
vim.keymap.set('n', '<D-s>', ':w<CR>', { desc = 'Save file' })

vim.api.nvim_create_user_command('Showmap', function(opts)
  local cmd = opts.args ~= '' and opts.args .. 'map' or 'map'
  vim.cmd('redir @a | silent ' .. cmd .. ' | redir END | new | put a')
  vim.bo.readonly = true
  vim.bo.modifiable = false
  vim.bo.buftype = 'nofile'  -- Don't treat as a real file
  vim.bo.bufhidden = 'wipe'  -- Delete buffer when hidden
end, { nargs = '?', desc = 'Show all key mappings in a seachable buffer' })

vim.api.nvim_create_user_command('Config', function()
  vim.cmd('e ~/.config/nvim/init.lua')
end, { desc = 'Show all key mappings in a seachable buffer' })

vim.api.nvim_create_user_command('Fmt', function()
  local filetype = vim.bo.filetype
  if filetype == 'ruby' or filetype == 'erb' then
    vim.cmd('!bundle exec rubocop -a %')
  elseif filetype == 'javascript' or filetype == 'typescript' then
    vim.cmd('!prettier --write %')
  elseif filetype == 'css' or filetype == 'scss' then
    vim.cmd('!prettier --write %')
  elseif filetype == 'sql' then
    vim.cmd('!sqlfluff fix % --dialect=postgres')
  else
    print('No formatter available for this file type: ' .. filetype)
  end
end, { desc = 'Format Ruby, JS, TS, CSS, or SCSS files using their respective formatters' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

vim.keymap.set('n', '<Leader>ww', ':bd<CR>')

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
elseif vim.fn.filereadable('/Users/sean/.asdf/shims/python') == 1 then
  vim.g.python3_host_prog = '/Users/sean/.asdf/shims/python'
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

vim.keymap.set('v', '<leader>y', '"+y', { noremap = true })

vim.keymap.set('v', '<D-c>', '"+y', { desc = 'Copy visual selection to system clipboard' })

-- Use ripgrep for searching
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
