return {
  -- 1) Gitsigns — core unchanged; keys moved to keys{} (buffer-local nav/textobjects kept)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "folke/which-key.nvim" },

    -- which-key v3: register Git groups early
    init = function()
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({
          { "<leader>g",  group = "Git" },
          { "<leader>gf", group = "Git: Find" }, -- for the Telescope git pickers below
        })
      end
    end,

    -- Global leader maps via Lazy's keys{}. Buffer-local nav/textobjects stay in on_attach.
    keys = {
      -- stage/reset current hunk (works in NORMAL & VISUAL)
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Stage Hunk", mode = { "n", "v" }, silent = true, noremap = true },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset Hunk", mode = { "n", "v" }, silent = true, noremap = true },

      -- buffer-wide actions
      { "<leader>gS", function() require("gitsigns").stage_buffer() end,         desc = "Stage Buffer",           mode = "n", silent = true, noremap = true },
      { "<leader>gu", function() require("gitsigns").undo_stage_hunk() end,      desc = "Undo Stage Hunk",        mode = "n", silent = true, noremap = true },
      { "<leader>gR", function() require("gitsigns").reset_buffer() end,         desc = "Reset Buffer",           mode = "n", silent = true, noremap = true },

      -- previews / blame / toggles
      { "<leader>gp", function() require("gitsigns").preview_hunk() end,         desc = "Preview Hunk (float)",   mode = "n", silent = true, noremap = true },
      { "<leader>gP", function() require("gitsigns").preview_hunk_inline() end,  desc = "Preview Hunk (inline)",  mode = "n", silent = true, noremap = true },
      { "<leader>gb", function() require("gitsigns").blame_line() end,           desc = "Blame Line",             mode = "n", silent = true, noremap = true },
      { "<leader>gB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Line Blame", mode = "n", silent = true, noremap = true },
      { "<leader>gd", function() require("gitsigns").diffthis() end,             desc = "Diff This (index)",      mode = "n", silent = true, noremap = true },
      { "<leader>gD", function() require("gitsigns").diffthis("~") end,          desc = "Diff Against HEAD",      mode = "n", silent = true, noremap = true },
      { "<leader>gt", function() require("gitsigns").toggle_deleted() end,       desc = "Toggle Deleted Lines",   mode = "n", silent = true, noremap = true },
      { "<leader>gx", function() require("gitsigns").toggle_signs() end,         desc = "Toggle Signs",           mode = "n", silent = true, noremap = true },
    },

    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "┃" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
      preview_config = { border = "single" },

      -- keep buffer-local nav & text objects here
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Hunk navigation (diff-aware)
        map("n", "]c", function() if vim.wo.diff then vim.cmd.normal({ "]c" }) else gs.next_hunk() end end, "Next Git Hunk")
        map("n", "[c", function() if vim.wo.diff then vim.cmd.normal({ "[c" }) else gs.prev_hunk() end end, "Prev Git Hunk")

        -- Hunk text objects
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Inner Hunk")
        map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "Around Hunk")
      end,
    },
  },

  -- 2) Neogit — full-screen Git UI (Magit-style). Lazy on command/keys.
  {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "folke/which-key.nvim",
      "nvim-telescope/telescope.nvim", -- for pickers below
      { "sindrets/diffview.nvim", optional = true }, -- nicer diffs
    },
    opts = {
      integrations = { diffview = true, telescope = true },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>",        desc = "Neogit (status)",     mode = "n", silent = true, noremap = true },
      { "<leader>gC", "<cmd>Neogit commit<CR>", desc = "Neogit Commit Popup", mode = "n", silent = true, noremap = true },
    },
    config = function(_, opts)
      require("neogit").setup(opts)
      -- which-key group already registered in gitsigns.init()
    end,
  },

  -- 3) Telescope Git pickers — convenient “find” sub-group under <leader>gf…
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    dependencies = { "folke/which-key.nvim" },
    keys = {
      { "<leader>gfc", function() require("telescope.builtin").git_commits() end,  desc = "Git: Commits",         mode = "n", silent = true, noremap = true },
      { "<leader>gfb", function() require("telescope.builtin").git_bcommits() end, desc = "Git: Buffer Commits",  mode = "n", silent = true, noremap = true },
      { "<leader>gfs", function() require("telescope.builtin").git_status() end,   desc = "Git: Status",          mode = "n", silent = true, noremap = true },
      { "<leader>gfB", function() require("telescope.builtin").git_branches() end, desc = "Git: Branches",        mode = "n", silent = true, noremap = true },
      { "<leader>gfS", function() require("telescope.builtin").git_stash() end,    desc = "Git: Stash",           mode = "n", silent = true, noremap = true },
    },
  },

  -- 4) (Optional) Diffview convenience keys, lazy on demand
  {
    "sindrets/diffview.nvim",
    optional = true,
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gV", "<cmd>DiffviewOpen<CR>",  desc = "Diffview: Open",  mode = "n", silent = true, noremap = true },
      { "<leader>gX", "<cmd>DiffviewClose<CR>", desc = "Diffview: Close", mode = "n", silent = true, noremap = true },
    },
  },
}
