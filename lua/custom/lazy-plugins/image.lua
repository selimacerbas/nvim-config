---------------------------------------------------------------------------
-- Image backend (required by diagram.nvim to draw images in terminal)
---------------------------------------------------------------------------
return {
    {
        "3rd/image.nvim",
        lazy = true,
        opts = {
            backend = "kitty",        -- "kitty" | "ueberzug" | "sixel"
            processor = "magick_cli", -- ImageMagick (`magick` or `convert`)
            max_width = 0,
            max_height = 0,
            max_width_window_percentage = 60,
            window_overlap_clear_enabled = true,
            editor_only_render_when_focused = true,
            tmux_show_only_in_active_window = true,
        },
        config = function(_, opts)
            require("image").setup(opts)
        end,
    },

    ---------------------------------------------------------------------------
    -- img-clip: paste images from clipboard/URL/file
    ---------------------------------------------------------------------------
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        dependencies = { "folke/which-key.nvim" },

        init = function()
            local ok, wk = pcall(require, "which-key")
            if ok then
                wk.add({
                    { "<leader>I", group = "Images / Clip" },
                })
            end
        end,

        keys = {
            { "<leader>Ip", "<cmd>PasteImage<cr>",                                    desc = "Paste image (clipboard)" },
            { "<leader>Iu", function() require("my_img_clip").paste_from_url() end,   desc = "Paste image from URL" },
            { "<leader>If", function() require("my_img_clip").paste_from_path() end,  desc = "Paste image from file path" },
            { "<leader>IB", function() require("my_img_clip").paste_base64() end,     desc = "Paste image as Base64 (one-shot)" },
            { "<leader>IA", function() require("my_img_clip").paste_absolute() end,   desc = "Paste using absolute path (one-shot)" },
            { "<leader>Id", function() require("my_img_clip").paste_into_dir() end,   desc = "Paste into custom dir (one-shot)" },
            { "<leader>IC", "<cmd>ImgClipConfig<cr>",                                 desc = "Show img-clip config" },
            { "<leader>ID", "<cmd>ImgClipDebug<cr>",                                  desc = "Show img-clip debug log" },
            { "<leader>IH", "<cmd>checkhealth img-clip<cr>",                          desc = "Health: img-clip" },
        },

        opts = {
            default = {
                dir_path = "assets",
                relative_to_current_file = true,
                prompt_for_file_name = true,
                insert_mode_after_paste = true,
                insert_template_after_cursor = true,
                drag_and_drop = { enabled = true, insert_mode = false },
            },
            filetypes = {
                markdown = {
                    url_encode_path = true,
                    template = "![$CURSOR]($FILE_PATH)",
                    download_images = false,
                },
                html = { template = '<img src="$FILE_PATH" alt="$CURSOR">' },
                tex = {
                    relative_template_path = false,
                    template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
          ]],
                },
                typst = {
                    template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
          ]],
                },
            },
        },

        config = function(_, opts)
            require("img-clip").setup(opts)

            local M = {}

            local function input(prompt, default, cb)
                vim.ui.input({ prompt = prompt, default = default or "" }, function(val)
                    if val and val ~= "" then cb(val) end
                end)
            end

            function M.paste_from_url()
                input("Image URL: ", "", function(url)
                    require("img-clip").paste_image({}, url)
                end)
            end

            function M.paste_from_path()
                input("Image file path: ", "", function(path)
                    require("img-clip").paste_image({}, path)
                end)
            end

            function M.paste_base64()
                require("img-clip").paste_image({ embed_image_as_base64 = true })
            end

            function M.paste_absolute()
                require("img-clip").paste_image({ use_absolute_path = true })
            end

            function M.paste_into_dir()
                input("Target dir (relative or absolute): ", "assets", function(dir)
                    require("img-clip").paste_image({ dir_path = dir })
                end)
            end

            package.loaded["my_img_clip"] = M
        end,
    },
}
