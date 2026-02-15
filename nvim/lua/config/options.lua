-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.tabstop = 4 -- Number of spaces a <Tab> in the file counts for
vim.opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 4 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.updatetime = 250 -- LSP hover timing
vim.opt.wrap = true --enable wrap

vim.g.root_spec = { "cwd" } -- open the current workind directory

vim.g.autoformat = false -- Disable autoformat on saving

if vim.g.neovide then
    vim.opt.guifont = "JetBrainsMono Nerd Font:h15"
    vim.g.neovide_opacity = 0.9
    vim.g.neovide_floating_blur_amount_x = 0.0
    vim.g.neovide_floating_blur_amount_y = 0.0
    vim.g.neovide_remember_window_size = false
    vim.opt.linespace = 2   -- try 1 or 2


    -- clear solid backgrounds so transparency shows through
    vim.cmd([[
        hi Normal guibg=NONE ctermbg=NONE
        hi NonText guibg=NONE ctermbg=NONE
        ]])
end
