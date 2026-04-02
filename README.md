# Neovim Config

Personal Neovim configuration for macOS, Linux, and Windows, focused on Python, Go, C/C++, Rust, and Lua development.

## Compatibility

- Tested on macOS with Homebrew Neovim.
- Shell and runner logic are written to work on both macOS and Linux.
- Windows is still supported with PowerShell, but the primary install path below now covers Unix-like systems as well.

## Stack

- Neovim 0.12+
- `lazy.nvim`
- `blink.cmp`
- `mason.nvim`
- native `vim.lsp`
- `conform.nvim`
- `telescope.nvim`
- `neo-tree.nvim`
- `gitsigns.nvim`
- `nvim-treesitter`
- `neoscroll.nvim`
- `smear-cursor.nvim`

## Included Language Support

- Python: `basedpyright`, `ruff`
- Go: `gopls`
- C/C++: `clangd`
- Rust: `rust-analyzer`
- Lua: `lua_ls`

## Highlights

- Modular config layout under `lua/config`, `lua/plugins`, and `after/lsp`
- File explorer on the left with `neo-tree`
- LSP navigation, rename, code actions, and diagnostics
- Format-on-save for supported languages
- Smooth scrolling and animated cursor
- Chinese tutor helpers: `:TutorZh` and `:TutorZh2`
- Run current file in a bottom terminal split with `<leader>ru`

## Requirements

- `git` for plugin bootstrapping
- `ripgrep` for Telescope live grep and file search
- `curl`, `tar`, and `unzip` for Mason downloads on most systems
- `tree-sitter` CLI for parser installation
- A C toolchain for Treesitter parsers and native dependencies
- A Nerd Font if you want icon rendering in `neo-tree` / Telescope

For clipboard integration:

- macOS: works with the built-in `pbcopy` / `pbpaste` provider
- Linux Wayland: install `wl-clipboard`
- Linux X11: install `xclip` or `xsel`

For `<leader>ru`, install the runtime or compiler you want to execute:

- Python: `python3` or `python`
- Go: `go`
- Rust: `cargo` / `rustc`
- C: `gcc` or `clang`
- C++: `g++` or `clang++`
- Lua: `lua` or `luajit`

## Install Neovim

### macOS

```bash
brew install neovim ripgrep tree-sitter-cli
```

If you want full clipboard + icon support, also make sure you use a Nerd Font in your terminal.

### Linux

Install the following with your distro package manager:

- `neovim`
- `ripgrep`
- `git`
- `curl`
- `tar`
- `unzip`
- `tree-sitter` or `tree-sitter-cli` depending on your distro package name
- `wl-clipboard` or `xclip` / `xsel` for clipboard support

If your distro ships an older Neovim, use a newer package source or the official release binaries so you have at least `0.12`.

### Windows

Install Neovim normally, then use the Windows config path shown below.

## Install This Config

Clone the repo into the correct config directory:

### macOS / Linux

```bash
git clone https://github.com/Arron196/nvim-config ~/.config/nvim
```

### Windows

```powershell
git clone https://github.com/Arron196/nvim-config $env:LOCALAPPDATA\nvim
```

## First Start

Start Neovim normally:

```bash
nvim
```

On first launch:

- `lazy.nvim` installs plugins automatically
- `mason.nvim` installs the configured LSP servers
- `nvim-treesitter` downloads parsers

Formatters, compilers, and language runtimes used by `conform.nvim` and `<leader>ru` are still external tools. Install them with your system package manager or language toolchain.

After startup, run `:checkhealth` if something looks off.

## Useful Keys

- `<leader>e`: toggle file explorer
- `<leader>ff`: find files
- `<leader>fg`: live grep
- `<leader>fb`: list buffers
- `<leader>fh`: help tags
- `<leader>fr`: recent files
- `<leader>cf`: format current buffer
- `<leader>ru`: run current file
- `<leader>sh`: horizontal split
- `<leader>sv`: vertical split
- `<leader>so`: keep only current window
- `<leader>se`: equalize windows
- `<S-h>` / `<S-l>`: previous / next buffer
- `<C-h/j/k/l>`: move across windows
