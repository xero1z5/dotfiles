return {
    "xeluxee/competitest.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "VeryLazy",
    opts = {
        local_config_file_name = ".competitest.lua",

        floating_border = "rounded",
        floating_border_highlight = "FloatBorder",

        picker_ui = {
            width = 0.2,
            height = 0.3,
            mappings = {
                focus_next = { "j", "<down>", "<Tab>" },
                focus_prev = { "k", "<up>", "<S-Tab>" },
                close = { "<esc>", "<C-c>", "q", "Q" },
                submit = "<cr>",
            },
        },

        editor_ui = {
            popup_width = 0.4,
            popup_height = 0.6,
            show_nu = true,
            show_rnu = false,
            normal_mode_mappings = {
                switch_window = { "<C-h>", "<C-l>", "<C-i>" },
                save_and_close = "<C-s>",
                cancel = { "q", "Q" },
            },
            insert_mode_mappings = {
                switch_window = { "<C-h>", "<C-l>", "<C-i>" },
                save_and_close = "<C-s>",
                cancel = "<C-q>",
            },
        },

        runner_ui = {
            interface = "popup",
            selector_show_nu = false,
            selector_show_rnu = false,
            show_nu = true,
            show_rnu = false,
            mappings = {
                run_again = "R",
                run_all_again = "<C-r>",
                kill = "K",
                kill_all = "<C-k>",
                view_input = { "i", "I" },
                view_output = { "a", "A" },
                view_stdout = { "o", "O" },
                view_stderr = { "e", "E" },
                toggle_diff = { "d", "D" },
                close = { "q", "Q" },
            },
            viewer = {
                width = 0.5,
                height = 0.5,
                show_nu = true,
                show_rnu = false,
                open_when_compilation_fails = true,
            },
        },

        popup_ui = {
            total_width = 0.8,
            total_height = 0.8,
            layout = {
                { 4, "tc" },
                { 5, { { 1, "so" }, { 1, "si" } } },
                { 5, { { 1, "eo" }, { 1, "se" } } },
            },
        },

        split_ui = {
            position = "right",
            relative_to_editor = true,
            total_width = 0.3,
            vertical_layout = {
                { 1, "tc" },
                { 1, { { 1, "so" }, { 1, "eo" } } },
                { 1, { { 1, "si" }, { 1, "se" } } },
            },
            total_height = 0.4,
            horizontal_layout = {
                { 2, "tc" },
                { 3, { { 1, "so" }, { 1, "si" } } },
                { 3, { { 1, "eo" }, { 1, "se" } } },
            },
        },

        save_current_file = true,
        save_all_files = false,
        compile_directory = ".",
        compile_command = {
            -- cpp = {
            --     exec = "g++",
            --     args = { "-std=c++20", "-g", "-Og", "-Wall", "$(FNAME)", "-o", "$(FNOEXT)" },
            -- },
            cpp = {
                exec = "g++",
                args = { "-std=c++20", "-O2", "-pipe", "-march=native", "-Wall", "$(FNAME)", "-o", "$(FNOEXT)" },
            },
        },
        running_directory = ".",
        run_command = {
            cpp = { exec = "./$(FNOEXT)" },
        },

        multiple_testing = -1,
        maximum_time = 5000,
        output_compare_method = "squish",
        view_output_diff = false,

        testcases_directory = ".",
        testcases_use_single_file = false,
        testcases_auto_detect_storage = true,
        testcases_single_file_format = "$(FNOEXT).testcases",
        testcases_input_file_format = "$(FNOEXT)_input$(TCNUM).txt",
        testcases_output_file_format = "$(FNOEXT)_output$(TCNUM).txt",

        companion_port = 27121,
        receive_print_message = true,
        start_receiving_persistently_on_setup = false,

        -- template_file = {
        --     cpp = "~/code/algo/template.cpp",
        -- },
        template_file = false,
        evaluate_template_modifiers = false,
        date_format = "%c",

        received_files_extension = "cpp",
        -- received_problems_path = "$(CWD)/$(CONTEST)/$(PROBLEM).$(FEXT)",

        -- received_problems_path = function(task, file_extension)
        --     -- remove leading/trailing spaces, then turn inner spaces into “_”
        --     local name = vim.trim(task.name):gsub("%s+", "_") -- <-- changed line
        --     return string.format("%s/%s.%s", vim.fn.getcwd(), name, file_extension)
        -- end,

        received_problems_path = function(task, ext)
            local dir = vim.fn.getcwd()

            -- grab contest-id and problem-letter directly from the URL
            local patterns = {
                "/problem/(%d+)/([A-Za-z])",
                "/contest/(%d+)/problem/([A-Za-z])",
                "/problemset/problem/(%d+)/([A-Za-z])",
            }

            -- test
            local contest_id, problem_id
            for _, pat in ipairs(patterns) do
                contest_id, problem_id = task.url:match(pat)
                if contest_id then
                    break
                end
            end
            contest_id = contest_id or "0"
            problem_id = (problem_id or "X"):upper()

            -- remove leading “A. ” / “B. ” etc. then turn spaces into “_”
            local title = vim.trim(task.name):gsub("^%a%.%s+", ""):gsub("%s+", "_")

            return string.format("%s/%s_%s_%s.%s", dir, contest_id, problem_id, title, ext)
        end,

        received_problems_prompt_path = true,
        received_contests_directory = "$(CWD)",
        received_contests_problems_path = "$(PROBLEM).$(FEXT)",
        received_contests_prompt_directory = true,
        received_contests_prompt_extension = true,
        open_received_problems = true,
        open_received_contests = true,
        replace_received_testcases = false,
    },

    keys = {
        {
            "<leader>r",
            "<cmd>CompetiTest receive problem<cr>",
            desc = "Competitest: Receive problem",
            silent = true,
            noremap = true,
        },
        {
            "<leader>t",
            "<cmd>CompetiTest receive contest<cr>",
            desc = "Competitest: Receive contest",
            silent = true,
            noremap = true,
        },
        {
            "<leader>j",
            "<cmd>CompetiTest run<cr>",
            desc = "Competitest: Run testcases",
            silent=true,
            noremap=true,
        },
    },
}
