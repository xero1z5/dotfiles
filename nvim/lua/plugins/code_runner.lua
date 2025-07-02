local function resolve_python()
    local cwd = vim.fn.getcwd()
    local candidates = { ".venv/bin/python", "venv/bin/python", ".env/bin/python" }
    for _, rel in ipairs(candidates) do
        local full = cwd .. "/" .. rel
        if vim.fn.executable(full) == 1 then
            return full .. " -u"
        end
    end
    return "python3 -u"
end

return {
    "CRAG666/code_runner.nvim",
    -- pass your settings directly to setup()
    config = function()
        require("code_runner").setup({
            -- choose float mode
            mode = "float",
            focus = true,
            startinsert = false,
            hot_reload = false,
            insert_prefix = "",

            -- floating window options
            float = {
                close_key = "<ESC>",
                border = "rounded", -- valid: "single"|"double"|"rounded"|"solid"|"shadow"|"none"
                height = 0.8, -- 80% of editor height
                width = 0.8, -- 80% of editor width
                x = 0.5, -- center horizontally
                y = 0.5, -- center vertically
                border_hl = "FloatBorder",
                float_hl = "Normal",
                blend = 0, -- no transparency
            },

            -- only these three languages
            filetype = {
                cpp = {
                    "cd $dir &&",
                    "g++ -std=c++20 -g -Og $fileName -o $fileNameWithoutExt &&", --> Removed the debug compiler and moved to manual keymap
                    -- "g++ -std=c++20 -O2 $fileName -o $fileNameWithoutExt &&",
                    "$dir/$fileNameWithoutExt",
                },
                python = resolve_python(),
                rust = {
                    "cd $dir &&",
                    "rustc $fileName -o $fileNameWithoutExt &&",
                    "$dir/$fileNameWithoutExt",
                },
            },

            -- optional hook before running
            before_run_filetype = function()
                vim.notify("Running code…", vim.log.levels.INFO)
            end,
        })

        -- Map Ctrl+n to :RunCode
        vim.keymap.set("n", "<C-n>", "<Cmd>RunCode<CR>", { noremap = true, silent = true, desc = "Run code in float" })
    end,
}
