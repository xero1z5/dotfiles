return {
    "folke/snacks.nvim",
    opts = {
        picker = {
            enabled = true,
            sources = {
                explorer = {
                    auto_close = true,
                    hidden = true,
                    layout = {
                        preset = "default",
                        preview = false,
                    },
                    -- Add custom actions for enhanced navigation
                    actions = {
                        search_in_directory = {
                            action = function(_, item)
                                if not item then
                                    return
                                end
                                local dir = vim.fn.fnamemodify(item.file, ":p:h")
                                Snacks.picker.grep({
                                    cwd = dir,
                                    hidden = true,
                                    ignored = true,
                                })
                            end,
                        },
                    },
                    win = {
                        list = {
                            keys = {
                                ["s"] = "search_in_directory",
                            },
                        },
                    },
                },
            },
        },
        image = {
            enabled = true,
            inline = true,
            float = true,
            backend = "ueberzug",
        },
    },
    keys = {
        -- Smart picker (frecency-based) for home directory
        {
            "<leader>fh",
            function()
                Snacks.picker.smart({ cwd = vim.fn.expand("~") })
            end,
            desc = "Smart Find (Home Directory)",
        },

        -- Grep across home directory
        {
            "<leader>fg",
            function()
                Snacks.picker.grep({ cwd = vim.fn.expand("~") })
            end,
            desc = "Grep (Home Directory)",
        },

        -- Directory picker for quick CD
        {
            "<leader>fd",
            function()
                vim.ui.input({
                    prompt = "Search directory from: ",
                    default = vim.fn.expand("~"),
                    completion = "dir",
                }, function(base_dir)
                    if base_dir then
                        Snacks.picker.files({
                            cwd = base_dir,
                            find_command = { "fd", "--type", "d", "--strip-cwd-prefix" },
                            attach_mappings = function(_, map)
                                map("i", "<CR>", function()
                                    local entry = require("snacks.picker").get_selection()
                                    if entry then
                                        local new_dir = base_dir .. "/" .. entry.filename
                                        vim.cmd("cd " .. new_dir)
                                        Snacks.notify.info("Changed to: " .. vim.fn.getcwd())
                                    end
                                end)
                                return true
                            end,
                        })
                    end
                end)
            end,
            desc = "Change Directory",
        },
    },
}
