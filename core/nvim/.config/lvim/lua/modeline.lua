local modeline = {}

modeline.generateModeline = function()
  local commentString = vim.opt.commentstring:get()

  local modelineElements =
  {
    -- ensure whitespace immediately after left side comment string
    (function()
      if string.match(commentString, "%s%%s") == nil then
        return " "
      end
      return ""
    end)(),

    "vi: set",

    (function()
      local encoding = vim.opt.fileencoding:get()
      if encoding ~= "utf-8" then
        return " fenc=" .. encoding
      end
      return ""
    end)(),

    " ft=" .. vim.opt.filetype:get(),
    " ts=" .. vim.opt.tabstop:get(),
    " sw=" .. vim.opt.shiftwidth:get(),
    " sts=" .. vim.opt.softtabstop:get(),

    (function()
      if vim.opt.shiftround:get() then
        return " sr"
      else
        return " nosr"
      end
    end)(),

    (function()
      if vim.opt.expandtab:get() then
        return " et"
      else
        return " noet"
      end
    end)(),

    (function()
      if vim.opt.smartindent:get() then
        return " si"
      else
        return " nosi"
      end
    end)(),

    " tw=" .. vim.opt.textwidth:get(),
    " fdm=" .. vim.opt.foldmethod:get(),

    (function()
      if vim.opt.foldmarker:get()[1] ~= "{{{" then
        return " fmr=" .. vim.opt.foldmarker:get()[1] .. "," .. vim.opt.foldmarker:get()[2]
      end
      return ""
    end)(),

    ":",

    -- ensure whitespace immediately before right side comment string if it exists
    (function()
      if string.match(commentString, "%%s$") == nil then
        return " "
      end
      return ""
    end)(),
  }

  local line = table.concat(modelineElements)
  return commentString:gsub("%%s", line)
end

modeline.insertModeline = function()
  local line        = modeline.generateModeline()
  local currentLine = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(0), 0, 1, true)[1]

  if string.match(currentLine, "vi:") then
    vim.api.nvim_buf_set_lines(0, 0, 1, true, { line })
  else
    vim.api.nvim_buf_set_lines(0, 0, 0, true, { line })
  end
end

return modeline