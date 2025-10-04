return
---------------------------------------------------------------------------
-- Image backend (required by diagram.nvim to draw images in terminal)
---------------------------------------------------------------------------
{
    "3rd/image.nvim",
    lazy = true,
    opts = {
        backend = "kitty",            -- "kitty" | "ueberzug" | "sixel"
        processor = "magick_cli",     -- ImageMagick (`magick` or `convert`)
        max_width = 0,
        max_height = 0,
        max_width_window_percentage = 60,
        window_overlap_clear_enabled = true,
        editor_only_render_when_focused = true,
        tmux_show_only_in_active_window = true,
    },
}
