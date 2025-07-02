-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

keymap("i", "jk", "<Esc>zz", opts)

-- Ctrl+A: Select All
keymap("n", "<C-a>", "ggVG", { desc = "Select all", silent = true })
keymap("i", "<C-a>", "<Esc>ggVG", { desc = "Select all", silent = true })
keymap("v", "<C-a>", "<Esc>ggVG", { desc = "Select all", silent = true })

-- Ctrl+Z: Undo
keymap("n", "<C-z>", "u", { desc = "Undo", silent = true })
keymap("i", "<C-z>", "<Esc>ui", { desc = "Undo", silent = true })
keymap("v", "<C-z>", "<Esc>u", { desc = "Undo", silent = true })

-- Ctrl+Y: Redo
keymap("n", "<C-y>", "<C-r>", { desc = "Redo", silent = true })
keymap("i", "<C-y>", "<Esc><C-r>i", { desc = "Redo", silent = true })
keymap("v", "<C-y>", "<Esc><C-r>", { desc = "Redo", silent = true })

-- Ctrl+C: Copy (in visual mode)
keymap("v", "<C-c>", '"+y', { desc = "Copy to clipboard", silent = true })

-- Ctrl+V: Paste
keymap("n", "<C-v>", '"+p', { desc = "Paste from clipboard", silent = true })
keymap("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard", silent = true })
keymap("v", "<C-v>", '"+p', { desc = "Paste from clipboard", silent = true })

-- Ctrl+X: Cut (in visual mode)
keymap("v", "<C-x>", '"+x', { desc = "Cut to clipboard", silent = true })

-- Ctrl+H: Find and Replace
keymap("n", "<C-h>", ":%s/", { desc = "Find and replace", silent = false })
keymap("v", "<C-h>", ":s/", { desc = "Find and replace in selection", silent = false })

-- Alt+Up/Down: Move lines up/down
keymap("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
keymap("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
keymap("i", "<A-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })
keymap("i", "<A-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })
keymap("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
keymap("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Leader-based duplication (Space + d + direction)
-- keymap("n", "<leader>du", ":t .-1<CR>", { desc = "Duplicate line up", silent = true })
-- keymap("n", "<leader>dd", ":t .<CR>", { desc = "Duplicate line down", silent = true })
-- keymap("i", "<leader>du", "<Esc>:t .-1<CR>gi", { desc = "Duplicate line up", silent = true })
-- keymap("i", "<leader>dd", "<Esc>:t .<CR>gi", { desc = "Duplicate line down", silent = true })
-- keymap("v", "<leader>du", ":t '<-1<CR>gv", { desc = "Duplicate selection up", silent = true })
-- keymap("v", "<leader>dd", ":t '><CR>gv", { desc = "Duplicate selection down", silent = true })

-- Remove the default terminal mapping for Ctrl+/
vim.keymap.del("n", "<C-/>", { silent = true })
vim.keymap.del("t", "<C-/>", { silent = true })

-- Map terminal to Ctrl+` (backtick) instead
keymap("n", "<C-`>", function()
    require("lazyvim.util").terminal()
end, { desc = "Terminal", silent = true })

-- Ctrl+/ for commenting
keymap("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
keymap("i", "<C-/>", "<Esc>gcca", { desc = "Toggle comment", remap = true })
keymap("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })

-- -- Ctrl+Shift+/ for adding comment above
-- keymap("n", "<C-c-/>", "gcO", { desc = "Add comment above", remap = true })
-- keymap("i", "<C-c-/>", "<Esc>gcOa", { desc = "Add comment above", remap = true })
--
-- keymap("n", "<C-x-/>", "gco", { desc = "Add comment above", remap = true })
-- keymap("i", "<C-x-/>", "<Esc>gcoa", { desc = "Add comment above", remap = true })

-- Tab for indenting in visual mode
keymap("v", ">", ">gv", { desc = "Indent selection", silent = true })
keymap("v", "<", "<gv", { desc = "Unindent selection", silent = true })

keymap("n", "<C-M-b>", function()
    vim.notify("Compiling in debug mode")
    vim.cmd("write")
    local file_path = vim.fn.expand("%:p") -- Full path
    local file_dir = vim.fn.expand("%:p:h") -- Directory

    -- Use vim.fn.shellescape() to properly quote the filename
    local escaped_file = vim.fn.shellescape(file_path)
    local output_path = vim.fn.shellescape(file_dir .. "/main")

    local cmd = string.format("g++ -std=c++20 -g -Og %s -o %s", escaped_file, output_path)
    local result = vim.fn.system(cmd)

    if vim.v.shell_error == 0 then
        vim.notify("Compilation successful!")
    else
        vim.notify("Compilation failed: " .. result, vim.log.levels.ERROR)
    end
end, { noremap = true, silent = true })

-- Stay centered while moving
-- keymap("n","jzz","j",{noremap = true, silent = true});
-- keymap("n","kzz","k",{noremap = true, silent = true});
