-- CODE HELPERS --
-- Show hover documentation
vim.api.nvim_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })

-- Jump to definition
vim.api.nvim_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })

-- Go to Declaration
vim.api.nvim_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', { noremap = true, silent = true })

-- Go to References
vim.api.nvim_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })

-- Go to Implementation
vim.api.nvim_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, silent = true })

-- Open code actions in normal mode and visual mode
vim.api.nvim_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })

-- Format Code
vim.api.nvim_set_keymap('n', '<leader>for', '<Cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })

-- Open diagnostic pop-up
vim.api.nvim_set_keymap('n', '<leader>dof', '<cmd>lua vim.diagnostic.open_float()<CR>', { noremap = true, silent = true })

-- Disable all diagnostics
vim.api.nvim_set_keymap('n', '<leader>dd', ':lua vim.diagnostic.disable()<CR>', { noremap = true, silent = true })

-- Enable all diagnostics
vim.api.nvim_set_keymap('n', '<leader>de', ':lua vim.diagnostic.enable()<CR>', { noremap = true, silent = true })

-- Open diagnostic list
vim.api.nvim_set_keymap('n', '<leader>dl', '<Cmd>lua vim.diagnostic.setloclist()<CR>', { noremap = true, silent = true })
-- END CODE HELPERS --




-- TAB CREATION --
-- Add key mapping to create a new tab
vim.api.nvim_set_keymap('n', '<leader>tab', ':tabnew<CR>', { noremap = true, silent = true })

-- Add key mapping to close the current tab
vim.api.nvim_set_keymap('n', '<leader>tabc', ':tabclose<CR>', { noremap = true, silent = true })

-- Mapping to open the custom tab picker
vim.api.nvim_set_keymap('n', '<leader>tabl', ':lua list_tabs()<CR>', { noremap = true, silent = true })

-- END TAB CREATION --




-- REPLACE PATTERN IN FILES --
-- Map <leader>pra to prompt for old and new patterns
vim.api.nvim_set_keymap('n', '<leader>rpf', [[:lua ReplacePatternInFiles(vim.fn.input("Old pattern: "), vim.fn.input("New pattern: "))<CR>]], { noremap = true, silent = true })

-- Map <leader>prf to prompt for old and new patterns, then replace interactively in all files.
vim.api.nvim_set_keymap('n', '<leader>rpfi', [[:lua ReplacePatternInFilesInteractively(vim.fn.input("Old pattern: "), vim.fn.input("New pattern: "))<CR>]], { noremap = true, silent = true })
-- END REPLACE PATTERN IN FILES --




-- PAGE ORIENTATION --
-- Adjust the view 5 line from the top when enter z + Enter.
vim.api.nvim_set_keymap('n', 'z<CR>', 'zt5<CR>', { noremap = true, silent = true })

-- Map <leader>hs to :split
vim.api.nvim_set_keymap('n', '<leader>hs', ':split<CR>', { noremap = true, silent = true })

-- Map <leader>vs to :vsplit
vim.api.nvim_set_keymap('n', '<leader>vs', ':vsplit<CR>', { noremap = true, silent = true })
-- END PAGE ORIENTATION --




-- NVIM-TREE --
-- Map <leader>nt to toggle nvim-tree
vim.api.nvim_set_keymap('n', '<leader>ntt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Map <leader>ntf to focus nvim-tree
vim.api.nvim_set_keymap('n', '<leader>ntf', ':NvimTreeFocus<CR>', { noremap = true, silent = true })

-- Key mappings to increase the width of nvim-tree by 10 columns
vim.api.nvim_set_keymap('n', '<leader>ntb', ':lua ResizeNvimTree(10)<CR>', { noremap = true, silent = true })

-- Key mappings to decrease the width of nvim-tree by 10 columns
vim.api.nvim_set_keymap('n', '<leader>nts', ':lua ResizeNvimTree(-10)<CR>', { noremap = true, silent = true })
-- NVIM-TREE ENDS --




-- TOGGLE-TERM --
-- Map <leader>ter to toggle terminal
vim.api.nvim_set_keymap('n', '<leader>ter', ':ToggleTerm<CR>', { noremap = true, silent = true })
-- TOGGLE-TERM ENDS --





-- TELESCOPE --
-- Map <leader>pff to find files in project.
vim.api.nvim_set_keymap('n', '<leader>tff', ':Telescope find_files<CR>', { noremap = true, silent = true })

-- Map <leader>pg to search content inside files. Uses grep or rg(ripgrep)
vim.api.nvim_set_keymap('n', '<leader>tlg', ':Telescope live_grep<CR>', { noremap = true, silent = true })

-- Map <leader>fw to search the current word under the cursor across your project.
vim.api.nvim_set_keymap('n', '<leader>tgs', ':Telescope grep_string<CR>', { noremap = true, silent = true })

-- Map <leader>pb to list buffers.
vim.api.nvim_set_keymap('n', '<leader>tbuf', ':Telescope buffers<CR>', { noremap = true, silent = true })

-- Map <leader>po to list old opened files.
vim.api.nvim_set_keymap('n', '<leader>tof', ':Telescope oldfiles<CR>', { noremap = true, silent = true })

-- Map <leader>fk to list all key mappings in your current Neovim session.
vim.api.nvim_set_keymap('n', '<leader>tkey', ':Telescope keymaps<CR>', { noremap = true, silent = true })
-- TELESCOPE ENDS --
