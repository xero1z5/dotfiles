return {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        lang = "cpp",
        plugins = { non_standalone = true },

        injector = {
            cpp = {
                before = {
                    "#include <bits/stdc++.h>",
                    "using namespace std;",
                },
                after = { "int main() {}" },
            },
        },

        picker = { provider = "snacks-picker" },
        image_support = false,
    },
    -- Set keymaps in the config function to ensure the plugin is loaded first
    config = function(_, opts)
        require("leetcode").setup(opts)
        local map = vim.keymap.set
        -- Create keymaps for normal mode
        map("n", "<leader>lr", "<cmd>Leet run<CR>", { desc = "Run Leetcode Problem" })
        map("n", "<leader>ls", "<cmd>Leet submit<CR>", { desc = "Submit Leetcode Problem" })
    end,
}
