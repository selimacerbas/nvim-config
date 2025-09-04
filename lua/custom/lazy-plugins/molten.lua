-- Installation + dependencies
-- brew install imagemagick
-- brew install pngpaste
-- Create venv in your python project and activate it.
-- Required; pip install pynvim jupyter_client jupyter_console ipykernel matplotlib pandas
-- Optional: pip install nbformat cairosvg plotly kaleido pyperclip pillow requests pnglatex
--
-- Check which kernels you have in your system
-- jupyter kernelspec list --json
--
-- Put this in ~/.zshrc: export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"
-- source ~/.zshrc


-- Create your penv specific Jupyter Kernel
-- pyenv activate tf2-env (change the name)
-- python -m ipykernel install --user --name=tf2-env --display-name "TensorFlow 2"
-- jupyter console --kernel tf2-env
--
-- Check which kernels you have in your system
-- jupyter kernelspec list --json

-- Run this to init the jupyter in your nvim.
-- :MoltenInit tf2-env
--


return {
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        cmd = {
            "MoltenInit", "MoltenInfo", "MoltenEvaluateLine", "MoltenEvaluateVisual",
            "MoltenEvaluateOperator", "MoltenReevaluateCell", "MoltenEnterOutput",
            "MoltenHideOutput", "MoltenShowOutput", "MoltenRestart", "MoltenDelete",
            "MoltenUpdateOption",
        },
        ft = { "python", "julia", "r" },

        dependencies = {
            {
                "3rd/image.nvim",
                opts = { rocks = { enabled = true, hererocks = true } },
                config = function()
                    require("image").setup({
                        backend = "kitty", -- or "ueberzug" if not on Kitty
                        processor = "magick_cli" -- brew install imagemagick
                    })
                end,
            },
            "folke/which-key.nvim",
        },

        -- IMPORTANT: also set your Python host at the very top of init.lua:
        --   vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/nvim-env/bin/python")

        init = function()
            -- Set Molten options BEFORE first use; after Molten initializes, use :MoltenUpdateOption
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_auto_open_output = true
            vim.g.molten_output_win_max_height = 20

            -- Let run-commands prompt for a kernel if none is attached (auto-init behavior).
            -- (If you want to change this later in-session: :MoltenUpdateOption auto_init_behavior <value>)
            -- Leaving it at Molten's default "prompt" behavior works well with the mappings below.
            -- vim.g.molten_auto_init_behavior = "prompt"   -- uncomment if you want to force it explicitly
        end,

        config = function()
            local function ensure_manifest()
                if vim.fn.exists(":MoltenInit") == 2 then return true end
                local manifest = vim.env.NVIM_RPLUGIN_MANIFEST or (vim.fn.stdpath("data") .. "/rplugin.vim")
                if vim.fn.filereadable(manifest) == 1 then pcall(vim.cmd.source, manifest) end
                return vim.fn.exists(":MoltenInit") == 2
            end

            -- convenience wrappers so keys never explode if manifest wasn’t sourced yet
            local function cmd_safe(ex_cmd)
                return function()
                    if not ensure_manifest() then
                        vim.notify("Molten not loaded. Run :Lazy rebuild | :UpdateRemotePlugins, then restart Neovim.",
                            vim.log.levels.ERROR)
                        return
                    end
                    vim.cmd(ex_cmd)
                end
            end

            local function visual_eval()
                if not ensure_manifest() then
                    vim.notify("Molten not loaded. Run :Lazy rebuild | :UpdateRemotePlugins, then restart Neovim.",
                        vim.log.levels.ERROR)
                    return
                end
                vim.cmd("'<,'>MoltenEvaluateVisual")
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gv", true, false, true), "n", false)
            end

            -- Auto-source manifest on relevant filetypes (so :Molten* exists in python/julia/r)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "python", "julia", "r" },
                callback = ensure_manifest,
            })

            local ok, wk = pcall(require, "which-key")
            if not ok then return end
            local add = wk.add or wk.register

            -- which-key group + mappings (conflict-free, descriptive)
            add({ { "<leader>j", group = "Jupyter (Molten)" } })

            -- Use Molten’s own prompt for kernels (works with shared kernels too)
            add({
                { "<leader>ji", cmd_safe("MoltenInit"),                  desc = "Init Kernel (prompt/attach)" },
                { "<leader>jI", cmd_safe("MoltenInfo"),                  desc = "Info / Health" },
                { "<leader>jl", cmd_safe("MoltenEvaluateLine"),          desc = "Run Line (auto-init)" },
                { "<leader>jo", cmd_safe("MoltenEvaluateOperator"),      desc = "Run Operator (then motion)" },
                { "<leader>jr", cmd_safe("MoltenReevaluateCell"),        desc = "Re-run Cell" },
                { "<leader>js", cmd_safe("MoltenShowOutput"),            desc = "Show Output" },
                { "<leader>jh", cmd_safe("MoltenHideOutput"),            desc = "Hide Output" },
                { "<leader>je", cmd_safe("noautocmd MoltenEnterOutput"), desc = "Enter Output (noautocmd)" },
                { "<leader>jd", cmd_safe("MoltenDelete"),                desc = "Delete Cell" },
                { "<leader>jR", cmd_safe("MoltenRestart"),               desc = "Restart Kernel" },
                -- Small helper to tweak options after init (see notes below)
                {
                    "<leader>j.",
                    function()
                        if not ensure_manifest() then
                            vim.notify("Molten not loaded.", vim.log.levels.ERROR); return
                        end
                        vim.ui.input({ prompt = "MoltenUpdateOption (name=value): " }, function(ans)
                            if not ans or ans == "" then return end
                            local name, value = ans:match("^%s*([^=%s]+)%s*=%s*(.+)%s*$")
                            if not name then
                                vim.notify("Format: name=value", vim.log.levels.WARN); return
                            end
                            vim.cmd(("MoltenUpdateOption %s %s"):format(name, value))
                        end)
                    end,
                    desc = "Update Option…"
                },
            }, { mode = "n", silent = true, noremap = true })

            add({
                { "<leader>jv", visual_eval, desc = "Run Visual (auto-init)" },
            }, { mode = "v", silent = true, noremap = true })
        end,
    },
}
