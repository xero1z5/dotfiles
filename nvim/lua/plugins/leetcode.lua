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
                -- either a plain table …
                before = {
                    "#include <bits/stdc++.h>",
                    "using namespace std;",
                },

                -- … or a function that returns one
                -- before = function()
                --   return {
                --     "#include <bits/stdc++.h>",
                --     "using namespace std;",
                --   }
                -- end,

                after = "int main() {}",
            },
        },

        picker = { provider = "snacks-picker" },
    },
}
