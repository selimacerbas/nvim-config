return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    dependencies = { "folke/which-key.nvim" },

    -- Use clean keys{}; no sizing presets. Global us*/uh* will handle sizes.
    keys = (function()
      -- cache a lazygit terminal if available (no custom sizing)
      local lazygit_term
      local function toggle_lazygit()
        if vim.fn.executable("lazygit") ~= 1 then
          vim.notify("lazygit not found in PATH", vim.log.levels.WARN)
          return
        end
        local Terminal = require("toggleterm.terminal").Terminal
        if not lazygit_term then
          lazygit_term = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
        end
        lazygit_term:toggle()
      end

      return {
        { "<leader>tt", function() vim.cmd("ToggleTerm direction=float") end,      desc = "Terminal (float)",      mode = "n", silent = true },
        { "<leader>th", function() vim.cmd("ToggleTerm direction=horizontal") end, desc = "Terminal (horizontal)", mode = "n", silent = true },
        { "<leader>tv", function() vim.cmd("ToggleTerm direction=vertical") end,   desc = "Terminal (vertical)",   mode = "n", silent = true },
        { "<leader>tg", toggle_lazygit,                                           desc = "LazyGit (float)",       mode = "n", silent = true },
      }
    end)(),

    config = function()
      local tt = require("toggleterm")

      tt.setup({
        -- ❌ no size/persist_size here; let your global us*/uh* handle it
        direction = "float",
        float_opts = { border = "curved", winblend = 5 },
        shade_terminals = false,
        start_in_insert = true,
        close_on_exit = true,
      })

      -- Transparent splits (non-floats)
      vim.api.nvim_set_hl(0, "ToggleTermTransparent", { bg = "NONE" })

      -- QoL for terminal buffers + make non-float splits transparent
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function(ev)
          -- normal-mode escape in terminal
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = ev.buf, silent = true, desc = "Terminal: normal mode" })
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false

          -- make non-float terminal windows transparent
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == ev.buf then
              local cfg = vim.api.nvim_win_get_config(win)
              local is_float = cfg and cfg.relative ~= "" and cfg.relative ~= nil
              if not is_float then
                local hl = table.concat({
                  "Normal:ToggleTermTransparent",
                  "NormalNC:ToggleTermTransparent",
                  "SignColumn:ToggleTermTransparent",
                  "EndOfBuffer:ToggleTermTransparent",
                }, ",")
                local ok = pcall(vim.api.nvim_set_option_value, "winhighlight", hl, { win = win })
                if not ok then pcall(vim.api.nvim_win_set_option, win, "winhighlight", hl) end
              end
            end
          end
        end,
      })

      -- which-key v3 labels (no sizing presets)
      local ok, wk = pcall(require, "which-key")
      if ok and wk.add then
        wk.add({
          { "<leader>t",  group = "Terminal" },
          { "<leader>tt", desc = "Terminal (float)" },
          { "<leader>th", desc = "Terminal (horizontal)" },
          { "<leader>tv", desc = "Terminal (vertical)" },
          { "<leader>tg", desc = "LazyGit (float)" },
        })
      end
    end,
  },
}
