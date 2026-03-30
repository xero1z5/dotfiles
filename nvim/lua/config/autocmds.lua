-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LSP Diagnostic Hover

local autocmd = vim.api.nvim_create_autocmd

local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = augroup("lsp_diagnostics_hold"),
    callback = function()
        vim.diagnostic.open_float(nil, {
            focus = false,
            scope = "cursor",
            border = "rounded",
        })
    end,
})

-- Menu to smart seach in home directory
local function quick_home_search()
    vim.ui.select({
        "Files",
        "Smart (Recent)",
        "Grep",
        "Directories",
    }, {
        prompt = "Search in home directory:",
    }, function(choice)
        local home = vim.fn.expand("~")
        if choice == "Files" then
            Snacks.picker.files({ cwd = home })
        elseif choice == "Smart (Recent)" then
            Snacks.picker.smart({ cwd = home })
        elseif choice == "Grep" then
            Snacks.picker.grep({ cwd = home })
        elseif choice == "Directories" then
            Snacks.picker.files({
                cwd = home,
                find_command = { "fd", "--type", "d" },
            })
        end
    end)
end

-- Keymap for quick menu search
vim.keymap.set("n", "<leader>fm", quick_home_search, { desc = "Quick Home Search Menu" })

-- Disble the insertion of comment in next line

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    desc = "Disable automatic comment continuation",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

