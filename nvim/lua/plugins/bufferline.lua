return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
        -- Other options you might have...
        options = {
            -- Add this 'offsets' table
            offsets = {
                {
                    filetype = "leetcode", -- The filetype for leetcode.nvim buffers
                    text = "LeetCode",
                    text_align = "center",
                    separator = true,
                },
            },
        },
    },
}
