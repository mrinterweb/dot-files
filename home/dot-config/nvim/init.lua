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

vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover()
end, { desc = "LSP Hover" })
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
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup()
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
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require('mason').setup()
      local lspconfig = require('lspconfig')
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local mason_lspconfig = require("mason-lspconfig")
      local servers = {
        ruby_lsp = {
          mason = false,
          cmd = { "~/.asdf/shims/ruby-lsp" },
        },
        ts_ls = {},
      }

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
          }
        end
      }
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
        --ruby = { "rubocop" },
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
    opts = {},
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

      vim.keymap.set({ "n", "v" }, "<leader>l", function()
        require('conform').format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 2000,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },
  -- Avante
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "ollama",
      ollama = {
        -- This modelfile is defined in ~/llm_configs/deep_coder_model
        -- Uses deepcoder:14b
        --model = "deep_coder_model",
        model = "qwen3:30b-a3b",
        options = {
          num_ctx = 40960,
          num_predict = 32768,
          temperature = 0.1,
        },
      },
      vendors = {
        --windows = {
          --__inherited_from = "openai",
          --api_key_name = "",
          --endpoint = "http://192.168.1.31:1234/v1",
          --model = "gemma-3-27b-it-qat",
          --disable_tools = true,
        --},
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      --"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      --"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      --"zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
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

-- Native neovim auto completion
--   This is not as fancy as blink, but a good fallback
--vim.api.nvim_create_autocmd('LspAttach', {
  --callback = function(ev)
    --local client = vim.lsp.get_client_by_id(ev.data.client_id)
    --if client:supports_method('textDocument/completion') then
      --vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    --end
  --end,
--})


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
