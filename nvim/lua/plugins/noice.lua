return {
    {
        "folke/noice.nvim",
        opts = function(_, opts)
            opts.cmdline = opts.cmdline or {}
            -- Use the popup cmdline UI
            opts.cmdline.view = "cmdline_popup"

            -- Configure views to center the cmdline (and keep the popupmenu aligned)
            opts.views = opts.views or {}

            -- Center the cmdline popup at the editor's center
            opts.views.cmdline_popup = vim.tbl_deep_extend("force", opts.views.cmdline_popup or {}, {
                position = { row = "50%", col = "50%" },
                size = { width = 60, height = "auto" },
                border = { style = "rounded", padding = { 0, 1 } },
                win_options = {
                    winhighlight = { Normal = "NoiceCmdlinePopup", FloatBorder = "NoiceCmdlinePopupBorder" },
                },
            })

            -- Optional: center the popupmenu below the cmdline
            opts.views.popupmenu = vim.tbl_deep_extend("force", opts.views.popupmenu or {}, {
                relative = "editor",
                position = { row = "58%", col = "50%" },
                size = { width = 60, height = 10 },
                border = { style = "rounded", padding = { 0, 1 } },
                win_options = {
                    winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
                },
            })
        end,
    },
}
