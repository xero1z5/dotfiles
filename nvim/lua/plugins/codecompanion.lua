return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        opts = {
            strategies = {
                chat = { adapter = "gemini" },
                inline = { adapter = "gemini" },
            },
            adapters = {
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        env = {
                            api_key = "cmd:sh -c 'cat ~/.secrets/gemini.key'",
                        },
                        -- Optional: pick a default model you have access to
                        schema = { model = { default = "gemini-2.5-flash" } },
                    })
                end,
            },
        },
    },
}
