return {

    -- File explorer: nvim-tree
    {
        'nvim-tree/nvim-tree.lua',
        config = function()
            local function my_on_attach(bufnr)
                local api = require('nvim-tree.api')

                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- Default mappings
                api.config.mappings.default_on_attach(bufnr)

                -- Mapping for opening a file in a new tab (t)
                vim.keymap.set('n', 't', api.node.open.tab, opts('Open File in New Tab'))
                vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))

                -- Custom mapping for navigating down and up with Tab and Shift-Tab
                vim.keymap.set('n', '<Tab>', api.node.navigate.sibling.next, opts('Navigate: Next Sibling'))
                vim.keymap.set('n', '<S-Tab>', api.node.navigate.sibling.prev, opts('Navigate: Previous Sibling'))

                -- Mapping for opening a file in a specific tab and split (T)
                vim.keymap.set('n', 'T', function()
                    local node = api.tree.get_node_under_cursor()
                    if not node or node.type ~= "file" then
                        print("Please select a file.")
                        return
                    end

                    -- Prompt for the tab number
                    local tab_number = tonumber(vim.fn.input("Enter Tab Number: "))
                    if not tab_number or tab_number < 1 or tab_number > vim.fn.tabpagenr('$') then
                        print("Invalid tab number!")
                        return
                    end

                    -- Switch to the specified tab
                    vim.cmd("tabnext " .. tab_number)

                    -- Prompt for split direction
                    local split_direction = vim.fn.input("Enter Split Direction (hs for horizontal, vs for vertical): ")
                    if split_direction ~= "hs" and split_direction ~= "vs" then
                        print("Invalid split direction!")
                        return
                    end

                    -- Perform the split
                    if split_direction == "hs" then
                        vim.cmd("split")
                    elseif split_direction == "vs" then
                        vim.cmd("vsplit")
                    end

                    -- Open the selected file in the split
                    vim.cmd("edit " .. node.absolute_path)
                end, opts('Open File in Tab with Split'))
            end

            require('nvim-tree').setup {
                disable_netrw = true, -- Optional customization, like disabling netrw (Recommended)
                hijack_netrw = true,
                view = {
                    side = 'left',
                    width = 40,
                },
                trash = {
                    cmd = "trash",
                    require_confirm = true
                },
                on_attach = my_on_attach, -- Attach custom mappings
            }
        end
    },

    -- Add more plugins below as needed
}
