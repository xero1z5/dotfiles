local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

------------------------------------------------------------------------------
--  Disable the arrow keys everywhere  ────────────────────────────────────
------------------------------------------------------------------------------
do
    local modes = { "n", "i", "v", "x", "s", "o", "c", "t" }
    local arrows = { "<Left>", "<Right>", "<Up>", "<Down>" }
    for _, m in ipairs(modes) do
        for _, k in ipairs(arrows) do
            keymap(m, k, "<Nop>", opts)
            -- or: keymap(m, k, '<Cmd>echo "Use hjkl!"<CR>', opts)
        end
    end
end

------------------------------------------------------------------------------
--  “jk” to escape insert mode and centre cursor
------------------------------------------------------------------------------
keymap("i", "jk", "<Esc>zz", opts)
keymap("v","jk","<Esc>zz",opts)

------------------------------------------------------------------------------
--  Windows / splits navigation with Ctrl-h/j/k/l
------------------------------------------------------------------------------
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

------------------------------------------------------------------------------
--  Classic shortcuts (select-all, undo, redo, clipboard, etc.)
------------------------------------------------------------------------------
-- Select All ---------------------------------------------------------------
keymap({ "n", "i", "v" }, "<C-a>", "<Cmd>normal! ggVG<CR>", { desc = "Select all", silent = true })

-- Undo / Redo --------------------------------------------------------------
keymap("n", "<C-z>", "u", { desc = "Undo", silent = true })
keymap("i", "<C-z>", "<Esc>ui", { desc = "Undo", silent = true })
keymap("v", "<C-z>", "<Esc>u", { desc = "Undo", silent = true })

keymap("n", "<C-y>", "<C-r>", { desc = "Redo", silent = true })
keymap("i", "<C-y>", "<Esc><C-r>i", { desc = "Redo", silent = true })
keymap("v", "<C-y>", "<Esc><C-r>", { desc = "Redo", silent = true })

-- System clipboard ---------------------------------------------------------
keymap("v", "<C-c>", '"+y', { desc = "Copy", silent = true })
keymap({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste", silent = true })
keymap("i", "<C-v>", "<C-r>+", { desc = "Paste", silent = true })
keymap("v", "<C-x>", '"+x', { desc = "Cut", silent = true })

-- Find & Replace -----------------------------------------------------------
keymap("n", "<C-h>", ":%s/", { desc = "Find & replace (buffer)", silent = false })
keymap("v", "<C-h>", ":s/", { desc = "Find & replace (visual)", silent = false })

------------------------------------------------------------------------------
--  Move lines / blocks  (Alt-↑ / Alt-↓ and J / K)
------------------------------------------------------------------------------
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })
keymap("i", "<A-k>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Same in visual with J / K -------------------------------------------------
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

------------------------------------------------------------------------------
--  Comment toggles  (gcc / gc)  and  terminal toggle
------------------------------------------------------------------------------
-- Remove LazyVim default <C-/> terminal mapping
vim.keymap.del("n", "<C-/>")
vim.keymap.del("t", "<C-/>")

-- Terminal on Ctrl-` --------------------------------------------------------
keymap("n", "<C-`>", function()
    require("lazyvim.util").terminal()
end, { desc = "Terminal", silent = true })

-- Comment toggling ----------------------------------------------------------
keymap("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
keymap("i", "<C-/>", "<Esc>gcca", { desc = "Toggle comment", remap = true })
keymap("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })

------------------------------------------------------------------------------
--  Indent / unindent while keeping selection
------------------------------------------------------------------------------
keymap("v", ">", ">gv", { desc = "Indent selection", silent = true })
keymap("v", "<", "<gv", { desc = "Unindent selection", silent = true })

------------------------------------------------------------------------------
--  Quality-of-life navigation tweaks
------------------------------------------------------------------------------
-- Half-page scroll & keep cursor centred ------------------------------------
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Keep search results centred ----------------------------------------------
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- Join line without moving the cursor --------------------------------------
keymap("n", "J", "mzJ`z", opts)

-- Paste over visual selection without losing register ----------------------
keymap("x", "<leader>p", '"_dP', opts)

------------------------------------------------------------------------------
--  Quick save / quit / toggle numbers
------------------------------------------------------------------------------
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- Keymaps for navigation in insert mode

keymap("i", "<C-h>", "<Left>", opts) -- left
keymap("i", "<C-j>", "<Down>", opts) -- down
keymap("i", "<C-k>", "<Up>", opts) -- up
keymap("i", "<C-l>", "<Right>", opts) -- right
keymap("i", "<C-e>", "<C-o>A", opts) -- move the end of the line


