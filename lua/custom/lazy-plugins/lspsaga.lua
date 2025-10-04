return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "folke/which-key.nvim",
      -- "nvim-treesitter/nvim-treesitter", -- optional but recommended by Saga docs
    },

    -- which-key v3: register LSP group early
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({ { "<leader>l", group = "LSP (Saga)" } })
      end
    end,

    opts = {
      finder = {
        keys = {
          toggle_or_open = "o",
          vsplit         = "s",
          split          = "i",
          tabe           = "t",
          tabnew         = "r",
          quit           = "q",
          close          = "<C-c>k",
        },
      },
      lightbulb = { enable = false },

      -- Required for Outline to work (breadcrumbs in winbar)
      symbols_in_winbar = { enable = true },
      -- outline = { layout = "normal" },
    },

    -- keys moved out of config; v3-friendly
    keys = {
      -- Core motions
      { "gh", "<cmd>Lspsaga finder<CR>",              desc = "Saga: Finder",          mode = "n", silent = true, noremap = true },
      { "gd", "<cmd>Lspsaga goto_definition<CR>",     desc = "Saga: Definition",      mode = "n", silent = true, noremap = true },
      { "gD", "<cmd>Lspsaga goto_declaration<CR>",    desc = "Saga: Declaration",     mode = "n", silent = true, noremap = true },
      { "gp", "<cmd>Lspsaga peek_definition<CR>",     desc = "Saga: Peek Definition", mode = "n", silent = true, noremap = true },

      -- Diagnostics (keeps clear space with gitsigns' [c ]c)
      { "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Diagnostics: Next",    mode = "n", silent = true, noremap = true },
      { "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Diagnostics: Prev",    mode = "n", silent = true, noremap = true },

      -- Leader helpers
      { "<leader>lh", "<cmd>Lspsaga hover_doc<CR>",                        desc = "Hover Doc",             mode = "n", silent = true, noremap = true },
      { "<leader>lH", "<cmd>Lspsaga hover_doc ++keep<CR>",                 desc = "Hover (pin)",           mode = "n", silent = true, noremap = true },

      { "<leader>lf", "<cmd>Lspsaga finder<CR>",                           desc = "Finder / References",   mode = "n", silent = true, noremap = true },
      { "<leader>lg", "<cmd>Lspsaga goto_definition<CR>",                  desc = "Go to Definition",      mode = "n", silent = true, noremap = true },
      { "<leader>lD", "<cmd>Lspsaga goto_declaration<CR>",                 desc = "Go to Declaration",     mode = "n", silent = true, noremap = true },
      { "<leader>lp", "<cmd>Lspsaga peek_definition<CR>",                  desc = "Peek Definition",       mode = "n", silent = true, noremap = true },

      { "<leader>la", "<cmd>Lspsaga code_action<CR>",                      desc = "Code Action",           mode = "n", silent = true, noremap = true },
      { "<leader>lr", "<cmd>Lspsaga rename<CR>",                           desc = "Rename Symbol",         mode = "n", silent = true, noremap = true },

      { "<leader>lR", "<cmd>Lspsaga show_line_diagnostics<CR>",            desc = "Line Diagnostics",      mode = "n", silent = true, noremap = true },
      { "<leader>ld", "<cmd>Lspsaga show_cursor_diagnostics<CR>",          desc = "Cursor Diagnostics",    mode = "n", silent = true, noremap = true },

      { "<leader>li", "<cmd>Lspsaga incoming_calls<CR>",                   desc = "Incoming Calls",        mode = "n", silent = true, noremap = true },
      { "<leader>lO", "<cmd>Lspsaga outgoing_calls<CR>",                   desc = "Outgoing Calls",        mode = "n", silent = true, noremap = true },

      { "<leader>lo", "<cmd>Lspsaga outline<CR>",                          desc = "Symbols Outline",       mode = "n", silent = true, noremap = true },

      { "<leader>lF", function() vim.lsp.buf.format({ async = true }) end, desc = "Format Buffer",         mode = "n", silent = true, noremap = true },
    },

    config = function(_, opts)
      require("lspsaga").setup(opts)
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    dependencies = { "folke/which-key.nvim" },

    -- register into same <leader>l group if needed
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({ { "<leader>l", group = "LSP (Saga)" } })
      end
    end,

    keys = {
      { "<leader>ls", function() vim.lsp.buf.signature_help() end,                desc = "Show Signature Help",     mode = "n", silent = true, noremap = true },
      { "<leader>lS", function() require("lsp_signature").toggle_float_win() end, desc = "Toggle Signature Float",  mode = "n", silent = true, noremap = true },
    },

    opts = function()
      local fn = vim.api.nvim_win_get_width
      return {
        bind = true,
        doc_lines = 5,
        wrap = true,
        max_height = 12,
        max_width = function() return math.floor(fn(0) * 0.8) end,

        floating_window = true,
        floating_window_above_cur_line = true,
        floating_window_off_x = 1,
        floating_window_off_y = 0,
        handler_opts = { border = "rounded" },

        hint_enable = true,
        hint_prefix = " ",
        hint_scheme = "String",
        hi_parameter = "LspSignatureActiveParameter",

        hint_inline = function() return "eol" end,

        extra_trigger_chars = { "(", "," },
        always_trigger = false,
        close_timeout = 4000,
        zindex = 200,
        padding = " ",
        transparency = nil,
        shadow_blend = 36,
        shadow_guibg = "Black",

        -- insert-mode keys handled by plugin internally
        toggle_key = "<M-s>",
        toggle_key_flip_floatwin_setting = true,
        select_signature_key = "<C-d>",
        move_signature_window_key = { "<C-k>", "<C-j>" },
        move_cursor_key = "<M-p>",
      }
    end,

    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
}
