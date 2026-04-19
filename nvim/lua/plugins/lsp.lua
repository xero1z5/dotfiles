return {
    -- Mason for managing language servers, formatters, and linters
    {
        "mason-org/mason.nvim",
        dependencies = {
            "mason-org/mason-lspconfig.nvim",
        },
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                -- Python
                "python-lsp-server", -- pylsp
                "ruff", -- ruff LSP server
                -- C/C++
                "clangd",
                "clang-format",
                "codelldb",
                -- Rust
                "rust-analyzer",
                -- C# / Unity
                "omnisharp",
                -- Java
                "jdtls",
            })
        end,
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Python LSP Server (pylsp)
                pylsp = {
                    settings = {
                        pylsp = {
                            plugins = {
                                -- Disable pylsp's formatting and linting (we'll use ruff)
                                autopep8 = { enabled = false },
                                flake8 = { enabled = false },
                                mccabe = { enabled = false },
                                pycodestyle = { enabled = false },
                                pydocstyle = { enabled = false },
                                pyflakes = { enabled = false },
                                pylint = { enabled = false },
                                yapf = { enabled = false },
                                -- Enable useful pylsp features
                                jedi_completion = { enabled = true },
                                jedi_hover = { enabled = true },
                                jedi_references = { enabled = true },
                                jedi_signature_help = { enabled = true },
                                jedi_symbols = { enabled = true },
                                rope_completion = { enabled = true },
                            },
                        },
                    },

                    single_file_support = true,

                    root_dir = function(fname)

                        if type(fname)~="string" then
                            return nil
                        end

                        local util = require("lspconfig.util")

                        local markers = {
                            "pyproject.toml",
                            "setup.py",
                            "setup.cfg",
                            "requirements.txt",
                            "Pipfile",
                            ".git",
                        }

                        local root = util.root_pattern(unpack(markers))(fname)
                        return root or vim.fs.dirname(fname)
                    end,
                },

                -- Ruff LSP for formatting and linting
                ruff = {
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    keys = {
                        {
                            "<leader>co",
                            function()
                                vim.lsp.buf.code_action({
                                    apply = true,
                                    context = {
                                        only = { "source.organizeImports" },
                                    },
                                })
                            end,
                            desc = "Organize Imports",
                        },
                    },
                },

                -- C/C++ Language Server
                clangd = {
                    cmd = {
                        -- "clangd",
                        -- "--background-index",
                        -- "--pch-storage=memory",
                        -- "--clang-tidy",
                        -- "--header-insertion=iwyu",
                        -- "--completion-style=detailed",
                        -- "--function-arg-placeholders",
                        -- "--fallback-style=llvm",
                        --
                        -- using coding with sphere args
                        "clangd",
                        "--background-index",
                        "--pch-storage=memory",
                        "--all-scopes-completion",
                        "--pretty",
                        "--header-insertion=never",
                        "-j=4",
                        "--inlay-hints",
                        "--header-insertion-decorators",
                        "--function-arg-placeholders",
                        "--completion-style=detailed",
                    },
                    init_options = {
                        usePlaceholders = true,
                        fallbackFlags = { "-std=c++2a" },
                    },
                    single_file_support = true,
                },

                -- Rust Language Server
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                runBuildScripts = true,
                            },
                            checkOnSave = {
                                allFeatures = true,
                                command = "clippy",
                                extraArgs = { "--no-deps" },
                            },
                            procMacro = {
                                enable = true,
                                ignored = {
                                    ["async-trait"] = { "async_trait" },
                                    ["napi-derive"] = { "napi" },
                                    ["async-recursion"] = { "async_recursion" },
                                },
                            },
                        },
                    },
                },

                -- C# / Unity
                omnisharp = {
                    cmd = { "omnisharp" },
                    settings = {
                        FormattingOptions = {
                            EnableEditorConfigSupport = true,
                        },
                        RoslynExtentionsOptions = {
                            EnableAnalyzersSupport = true,
                            EnableImportCompletion = true,
                        },
                    },
                },
            },

            setup = {
                ruff = function()
                    vim.api.nvim_create_autocmd("LspAttach", {
                        callback = function(args)
                            local client = vim.lsp.get_client_by_id(args.data.client_id)
                            if client and client.name == "ruff" then
                                client.server_capabilities.hoverProvider = false
                            end
                        end,
                    })
                end,
            },
        },
    },

    -- Formatting configuration
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" },
                c = { "clang_format" },
                cpp = { "clang_format" },
            },
            formatters = {
                ruff_format = {
                    command = "ruff",
                    args = { "format", "--stdin-filename", "$FILENAME", "-" },
                    stdin = true,
                },
                ruff_organize_imports = {
                    command = "ruff",
                    args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" },
                    stdin = true,
                },
            },
        },
    },

    -- Linting configuration
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                python = { "ruff" },
            },
        },
    },

    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "python",
                "c",
                "cpp",
                "rust",
                "c_sharp",
                "java",
            })
        end,
    },
    
    -- Java LSP
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
    },
}
