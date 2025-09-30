return {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first

    config = function()
        require("onedarkpro").setup({

            styles = { -- For example, to apply bold and italic, use "bold,italic"
                types = "NONE", -- Style that is applied to types
                methods = "bold", -- Style that is applied to methods
                numbers = "NONE", -- Style that is applied to numbers
                strings = "italic", -- Style that is applied to strings
                comments = "italic", -- Style that is applied to comments
                keywords = "bold", -- Style that is applied to keywords
                constants = "NONE", -- Style that is applied to constants
                functions = "bold,italic", -- Style that is applied to functions
                operators = "NONE", -- Style that is applied to operators
                variables = "NONE", -- Style that is applied to variables
                parameters = "NONE", -- Style that is applied to parameters
                conditionals = "NONE", -- Style that is applied to conditionals
                virtual_text = "NONE", -- Style that is applied to virtual text
            },

            options = {
                transparency = true,
            },
        })
        vim.cmd("colorscheme onedark")
    end,
}

-- return {
--     "EdenEast/nightfox.nvim",
--     lazy = false,
--     priority = 1000, -- Make sure to load this before other plugins
--
--     opts = {
--         options = {
--             -- Your preferred theme. Can be one of "nightfox", "dayfox", "dawnfox", "terafox", "carbonfox"
--             style = "carbonfox",
--
--             -- Set the background to transparent.
--             transparent = true,
--
--             -- Plugin integrations
--             integrations = {
--                 treesitter = true,
--                 native_lsp = true,
--                 gitsigns = true,
--                 nvimtree = true,
--                 telescope = true,
--                 -- etc.
--             },
--
--             -- Stylize language elements
--             styles = { -- For example, to apply bold and italic, use "bold,italic"
--                 comments = "italic", -- Style that is applied to comments
--                 conditionals = "NONE", -- Style that is applied to conditionals
--                 constants = "NONE", -- Style that is applied to constants
--                 functions = "bold,italic", -- Style that is applied to functions
--                 keywords = "bold", -- Style that is applied to keywords
--                 numbers = "NONE", -- Style that is applied to numbers
--                 operators = "NONE", -- Style that is applied to operators
--                 strings = "italic", -- Style that is applied to strings
--                 types = "NONE", -- Style that is applied to types
--                 variables = "NONE", -- Style that is applied to variables
--             },
--         },
--     },
--
--     config = function(_, opts)
--         -- Load the theme
--         require("nightfox").setup(opts)
--         vim.cmd.colorscheme(opts.options.style)
--     end,
-- }
