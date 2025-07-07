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







