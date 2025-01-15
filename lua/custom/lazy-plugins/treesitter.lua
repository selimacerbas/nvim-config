return {

    -- nvim-treesitter for syntax highlighting and more
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate", -- Automatically install/update language parsers
        config = function()
            require('nvim-treesitter.configs').setup {
                -- List of languages to be installed
                ensure_installed = {
                    "rust",
                    "go",
                    "c",
                    "cpp",
                    "python",
                    "json",
                    "yaml",
                    "dart",
                    "javascript",
                    "lua",
                    "vimdoc",
                    "typescript",
                    "vim",
                    "query",
                    "terraform",
                    "dockerfile",
                    "bash",
                    "cmake",
                    "helm",
                    "html",
                    "xml",
                    "hcl",
                    "starlark"
                },
                highlight = {
                    enable = true, -- Enable syntax highlighting
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true, -- Enable indentation based on treesitter
                },
                playground = {
                    enable = true,           -- Enable the Treesitter playground
                    updatetime = 25,         -- Debounce time for highlighting nodes
                    persist_queries = false, -- Whether the query persists across sessions
                },
            }
        end
    },
    -- Treesitter playground
    {
        "nvim-treesitter/playground",
        cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
    },
    -- Helm-specific syntax highlighting
    {
        "towolf/vim-helm",
        ft = { "helm", "yaml" },
    },

    -- Add more plugins below as needed
}
