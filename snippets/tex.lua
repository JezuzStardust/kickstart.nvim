local function math()
  -- Assuming vimtex is installed and available
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

local function in_math_mode_treesitter()
  -- Need to remove latex from the disabled highlights in the treesitter config to use this function.
  local node = ls.get_node()
  if node and node:type() == 'math_environment' then
    return true
  end
end

return {
  s('template', {
    t {
      '\\documentclass[a4paper]{article}',
      '\\usepackage{a4wide}',
      '\\usepackage[utf8]{inputenc}',
      '\\usepackage[T1]{fontenc}',
      '\\usepackage{textcomp}',
      '\\usepackage[',
    },
    c(1, { t 'english', t 'swedish' }),
    t {
      ']{babel}',
      '\\usepackage{amsmath, amssymb}',
      '\\usepackage{bm}',
      '',
      '\\begin{document}',
      '\\title{',
    },
    i(2, 'title'),
    t { '}', '\\author{Jens Zamanian}', '', '' },
    i(3, 'text'),
    t { '', '', '\\end{document}' },
  }),
}, {
  s('alpha', { t '\\alpha' }, { condition = math }),
  s('beta', { t '\\beta' }, { condition = math }),
  s('gamma', { t '\\gamma' }, { condition = math }),
  s('sigma', { t '\\sigma' }, { condition = math }),
  s('delta', { t '\\delta' }, { condition = math }),
  s('chi', { t '\\chi' }, { condition = math }),
  s('xi', { t '\\xi' }, { condition = math }),
  s('psi', { t '\\psi' }, { condition = math }),

  s({ trig = 'sr', wordTrig = false }, { t '^2' }, { condition = math }),
}
