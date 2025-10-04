return {
    {
        "windwp/nvim-autopairs",
        -- event = "InsertEnter", -- keep commented lazy-load hint
        dependencies = { "folke/which-key.nvim" },
        opts = function()
            -- Only turn on Treesitter-aware pairing if TS is installed
            local has_ts = pcall(require, "nvim-treesitter.parsers")

            return {
                check_ts = has_ts,
                ts_config = {
                    -- don't pair inside strings/comments (when TS is available)
                    lua = { "string", "comment" },
                    javascript = { "template_string", "string", "comment" },
                    java = false, -- keep Java simple (no TS checks)
                },

                -- keep your custom ignores
                disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },

                -- keep fast-wrap feature as-is (doesn't add leader mappings)
                fast_wrap = {
                    map = "<M-e>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = [=[[%'%"%>%]%)%}%,]]=],
                    end_key = "$",
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    cursor_pos = true,
                },

                -- small quality-of-life tweaks
                enable_check_bracket_line = false, -- add pairs even if a closing exists later on the line
                map_c_h = true,            -- <C-h> deletes pair intelligently in insert mode
                map_c_w = true,            -- <C-w> deletes pair word-wise in insert mode
            }
        end,
        config = function(_, opts)
            local npairs = require("nvim-autopairs")
            local Rule   = require("nvim-autopairs.rule")
            local cond   = require("nvim-autopairs.conds")

            npairs.setup(opts)

            -- TeX $$…$$ rule, but don’t pair if next char is %
            npairs.add_rule(
                Rule("$$", "$$", "tex")
                :with_pair(cond.not_after_regex("%%"))
            )

            -- Space inside brackets: (|) -> ( | ), etc.
            npairs.add_rules({
                Rule(" ", " ")
                    :with_pair(function(ctx)
                        local pair = ctx.line:sub(ctx.col - 1, ctx.col)
                        return pair == "()" or pair == "[]" or pair == "{}"
                    end),
            })

            -- Optional nvim-cmp integration (auto-insert () after confirm)
            local ok_cmp, cmp = pcall(require, "cmp")
            if ok_cmp then
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
            end

        end,
    },
}
