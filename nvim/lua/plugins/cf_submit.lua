
return {
  "nvim-lua/plenary.nvim",   -- already in LazyVim but safe to list
  config = function()
    local s = require("custom.cf_submit")

    vim.api.nvim_create_user_command("CFSubmit", s.submit, {})
    vim.keymap.set("n", "<leader>k", s.submit,
      { desc = "Submit to Codeforces (term)" })
  end,
}
