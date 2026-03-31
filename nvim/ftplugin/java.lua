local config = {
    cmd = { "jdtls" },
    root_dir = vim.fs.dirname(
        vim.fs.find({ "gradlew", "build.gradle", "pom.xml", ".git" }, { upward = true })[1]
    ),
    data_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
    settings = {
        java = {
            configuration = {
                runtimes = {
                    {
                        name = "JavaSE-21",
                        path = "/usr/lib/jvm/java-21-openjdk/",
                        default = true,
                    },
                },
            },
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            inlayHints = { parameterNames = { enabled = "all" } },
            format = { enabled = true },
        },
        signatureHelp = { enabled = true },
    },
}

require("jdtls").start_or_attach(config)
