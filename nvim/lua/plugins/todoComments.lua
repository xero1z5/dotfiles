return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {

        signs = true, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- -- keywords recognized as todo comments
        -- keywords = {
        --     FIX = { icon = " ", color = "#ff0f53", alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "bug" } },
        --     TODO = { icon = " ", color = "#0fe3ff", alt = { "todo" } },
        --     HACK = { icon = " ", color = "warning" },
        --     WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", "warn" } },
        --     PERF = { icon = " ", color = "#b46efa", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "optim" } },
        --     NOTE = { icon = " ", color = "#0fff23", alt = { "INFO", "note", "info" } },
        --     TEST = { icon = " ", color = "#0fff93", alt = { "TESTING", "PASSED", "FAILED" } },
        -- },

    },
}

--bug:
--todo:
--HACK:
--optim:
--note:
--TEST:
--
