# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dot-files repository for managing personal configuration files including:
- Neovim configuration (init.lua with lazy.nvim plugin manager)
- Zsh configuration (with oh-my-zsh)
- Tmux configuration
- Various shell scripts and utilities

## Common Commands

### Installation
```bash
# Link all dot files to home directory
rake
# or
rake install
```

### Neovim Development
```bash
# The main configuration file is at:
# home/dot-config/nvim/init.lua

# Key plugin configurations:
# - LSP: Mason + mason-lspconfig for Ruby and TypeScript
# - Fuzzy finder: Telescope (Ctrl+P for files, Ctrl+G for grep)
# - Completion: blink.cmp with LSP and Avante integration
# - Testing: vim-test (t<C-n> for nearest test, t<C-f> for file)
# - Git: Neogit, fugitive, and gitsigns
```

### Shell Scripts
- `sb` - Smart git branch switcher with SQLite history and notes
- `rb` - Ruby one-liner execution tool for command line piping
- `copy_code_to_clipboard` - Utility for copying code
- `genctags` - CTags generation script
- `svgoptimize` - SVG optimization utility

## Architecture

The repository uses a custom naming convention where dot files are prefixed with `dot-` (e.g., `dot-vimrc` becomes `.vimrc` when linked). The Rakefile handles symlinking with:
- Color-coded output for status
- Conflict detection
- Directory creation as needed

## Key Configuration Details

### Neovim
- Uses Lua configuration with lazy.nvim for plugin management
- LSP configured with asdf shims for Ruby (`~/.asdf/shims/ruby-lsp`)
- Test runner configured for RSpec with fail-fast
- Multiple escape mappings (jj, jk, kj, kk for save)
- Leader key set to space

### Shell Environment
- Zsh with oh-my-zsh and plugins: git, gitfast, bundler, history-substring-search, mix, docker, fzf
- asdf version manager integration
- Custom PATH additions for various tools
- Work-specific settings loaded from `~/.work-settings` if present