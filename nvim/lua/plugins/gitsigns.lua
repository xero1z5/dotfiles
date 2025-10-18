return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end, { expr = true, buffer = bufnr, desc = "Go to previous hunk" })
      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end, { expr = true, buffer = bufnr, desc = "Go to next hunk" })
      vim.keymap.set("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", { buffer = bufnr, desc = "Stage hunk" })
      vim.keymap.set("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", { buffer = bufnr, desc = "Reset hunk" })
    end,
  },
}
