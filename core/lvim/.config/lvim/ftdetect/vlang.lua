vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" },
  { pattern = { "*.v" }, callback = function() vim.opt.filetype = "vlang" end })
