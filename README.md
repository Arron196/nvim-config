# Neovim Config

Personal Neovim configuration for Windows, focused on Python, Go, C/C++, and Rust development.

## Stack

- Neovim 0.12
- lazy.nvim
- blink.cmp
- mason.nvim
- native `vim.lsp`
- conform.nvim
- telescope.nvim
- neo-tree.nvim
- gitsigns.nvim
- neoscroll.nvim
- smear-cursor.nvim

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

## Useful Keys

- `<leader>e`: toggle file explorer
- `<leader>ff`: find files
- `<leader>fg`: live grep
- `<leader>cf`: format current buffer
- `<leader>ru`: run current file
- `<leader>sh`: horizontal split
- `<leader>sv`: vertical split
- `<leader>so`: keep only current window
- `<leader>se`: equalize windows
- `<S-h>` / `<S-l>`: previous/next buffer
- `<C-h/j/k/l>`: move across windows

## Startup

Clone this repository to:

```text
%LOCALAPPDATA%\nvim
```

Then start Neovim normally:

```powershell
nvim
```

Plugins and external tools are managed through `lazy.nvim` and `mason.nvim`.
