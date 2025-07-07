-- Replace a pattern with a new one recursively in files.
function ReplacePatternInFiles(old_pattern, new_pattern)
    local cwd = vim.loop.cwd() -- Get the current working directory
    print("Starting directory: " .. cwd)

    local proceed = vim.fn.input("Do you want to continue? (y/n): ") -- Ask for confirmation
    if proceed:lower() ~= 'y' then
        print("Operation canceled.")
        return
    end

    -- Escape patterns for sed
    local escaped_old_pattern = vim.fn.escape(old_pattern, '/\\')
    local escaped_new_pattern = vim.fn.escape(new_pattern, '/\\')

    -- Construct the sed command
    local command = "grep -rl '" ..
        escaped_old_pattern ..
        "' " .. cwd .. " | xargs sed -i '' 's/" .. escaped_old_pattern .. "/" .. escaped_new_pattern .. "/g'"

    -- Execute the command
    local result = vim.fn.system(command)

    -- Display modified files
    if result ~= "" then
        print("Modified files:\n" .. result)
    else
        print("No files were modified.")
    end
end

-- Interactively replace a pattern in files within the current folder.
function ReplacePatternInFilesInteractively(old_pattern, new_pattern)
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values


    local cwd = vim.loop.cwd() -- Get the current working directory
    print("Starting directory: " .. cwd)

    local proceed = vim.fn.input("Do you want to continue? (y/n): ") -- Ask for confirmation
    if proceed:lower() ~= 'y' then
        print("Operation canceled.")
        return
    end

    -- Escape special characters
    local escaped_old_pattern = vim.fn.escape(old_pattern, '/\\')
    local escaped_new_pattern = vim.fn.escape(new_pattern, '/\\')

    -- Find all files containing the pattern
    local grep_command = "grep -rl '" .. escaped_old_pattern .. "' " .. cwd
    local file_list = vim.fn.systemlist(grep_command)

    if #file_list == 0 then
        print("No files found containing the pattern.")
        return
    end

    -- Iterate over files and perform replacement
    for _, file in ipairs(file_list) do
        print("Processing file: " .. file)
        vim.cmd("edit " .. file)
        vim.cmd(string.format("%%s/%s/%s/gc", escaped_old_pattern, escaped_new_pattern))
        vim.cmd("write")
        vim.cmd("bdelete")
    end

    print("Finished interactive replacement in files under " .. cwd)
end
