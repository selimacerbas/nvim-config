# Neovim Configuration

Personal Neovim configuration using lazy.nvim as the plugin manager.

## Structure

```
nvim/
├── init.lua                  # Entry point - loads lua/custom/init.lua
├── lazy-lock.json            # Plugin version lockfile
└── lua/custom/
    ├── init.lua              # Core settings, options, autocommands
    ├── lazy.lua              # lazy.nvim bootstrap + plugin spec imports
    ├── ui-sizing.lua         # Custom window sizing module
    └── lazy-plugins/         # Individual plugin configurations
        ├── snippets/         # LuaSnip snippet definitions
        └── theme/            # Color scheme configs
```

## Key Conventions

- **One plugin per file**: Each plugin has its own file in `lazy-plugins/`
- **Lazy loading**: Use `event`, `cmd`, `keys`, or `ft` for deferred loading
- **Leader key**: `<Space>` is the leader, `,` is local leader
- **Plugin spec pattern**:
  ```lua
  return {
      {
          "author/plugin",
          dependencies = {},
          event = "VeryLazy",  -- or cmd/keys/ft
          opts = {},
          config = function() end,
      }
  }
  ```

## Important Files

- `lua/custom/init.lua` - Editor options, Python provider path, autocommands
- `lua/custom/lazy.lua` - Plugin manager setup and all plugin imports
- `lua/custom/lazy-plugins/nvim-lspconfig.lua` - LSP server configurations
- `lua/custom/lazy-plugins/nvim-cmp.lua` - Completion with custom sorting/biasing
- `lua/custom/lazy-plugins/mason.lua` - Mason, formatters, linters setup
- `lua/custom/lazy-plugins/telescope.lua` - Fuzzy finder config
- `lua/custom/ui-sizing.lua` - Custom per-window sizing system

## LSP Servers Configured

rust_analyzer, clangd, terraformls, pyright, jsonls, yamlls, ts_ls, lua_ls, gopls, dockerls, bashls, helm_ls, html, lemminx, cmake, texlab, cssls, ruff

## Keybinding Prefixes

| Prefix | Purpose |
|--------|---------|
| `<leader>T` | Telescope |
| `<leader>n` | NvimTree |
| `<leader>c` | Copilot |
| `<leader>d` | Debug (DAP) |
| `<leader>l` | LSP utilities |
| `<leader>h` | MCPHub |
| `<leader>A` | Claude Code |
| `<leader>t` | Terminal |
| `<leader>U` | Snacks/utilities |
| `<leader>ut` | UI sizing |
| `<leader>UC` | Completion biasing |

## Python Environment

Uses pyenv virtualenv at `~/.pyenv/versions/nvim-env/bin/python` for pynvim.

## Commands

- `:Lazy` - Plugin manager UI
- `:Mason` - LSP/tool installer UI
- `:LspInfo` - Active LSP clients
- `:LspToggleInlayHints` - Toggle inlay hints
- `:LspDedupeHere` - Kill duplicate LSP clients
- `:ConformInfo` - Formatter status
- `:TSPlaygroundToggle` - Treesitter playground

## Adding a New Plugin

1. Create `lua/custom/lazy-plugins/plugin-name.lua`
2. Add the plugin spec in the return table
3. Add `{ import = "custom.lazy-plugins.plugin-name" }` to `lazy.lua`
4. Run `:Lazy sync`

## Adding a New LSP Server

1. Add server name to `ensure_installed` in `mason.lua`
2. Add server config in `nvim-lspconfig.lua` under `servers` table
3. Run `:MasonInstall <server-name>` or restart Neovim
