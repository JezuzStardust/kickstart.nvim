require 'luasnip.extras.fmt'
local line_begin = require('luasnip.extras.conditions.expand').line_begin
-- require 'luasnip.extras.conditions.expand.line_begin'
local function fn_math()
  -- Assuming vimtex is installed and available
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
local math = require('luasnip.extras.conditions').make_condition(fn_math)

-- local function in_math_mode_treesitter()
-- Need to remove latex from the disabled highlights in the treesitter config to use this function.
-- local node = ls.get_node()
-- if node and node:type() == 'math_environment' then
--   return true
-- end
-- end

return {
  s( -- 'template'
    { trig = 'template', name = 'LaTeX Template', desc = 'Create LaTeX template' },
    fmt(
      [[
      \documentclass[a4paper]{article}
      \usepackage{a4wide}
      \usepackage[utf8]{inputenc}
      \usepackage[T1]{fontenc}
      \usepackage{textcomp}
      \usepackage[<>]{babel}
      \usepackage{amsmath, amssymb}
      \usepackage{bm}

      \begin{document}
      \title{<>}
      \author{Jens Zamanian}

      <>

      \end{document}
      ]],
      {
        c(1, { t 'english', t 'swedish' }),
        i(2, 'title'),
        i(0),
      },
      {
        delimiters = '<>',
      }
    ),
    { condition = line_begin * -math }
  ),
}, {
  -- Math symbols
  s('alpha', { t '\\alpha' }, { condition = math }),
  s('beta', { t '\\beta' }, { condition = math }),
  s('gamma', { t '\\gamma' }, { condition = math }),
  s('sigma', { t '\\sigma' }, { condition = math }),
  s('delta', { t '\\delta' }, { condition = math }),
  s('chi', { t '\\chi' }, { condition = math }),
  s('xi', { t '\\xi' }, { condition = math }),
  s('psi', { t '\\psi' }, { condition = math }),
  s('pi', { t '\\pi' }, { condition = math }),
  s('inf', { t '\\infty' }, { condition = math }),

  s({ trig = 'sr', wordTrig = false }, { t '^2' }, { condition = math }),
  s( -- Square root
    { trig = 'sq', name = 'Square root', wordTrig = false },
    fmt(
      [[
        \sqrt{<>}<>
        ]],
      { i(1), i(0) },
      { delimiters = '<>' }
    ),
    { condition = math }
  ),
  -- Environments
  s( -- 'beg'
    'beg',
    fmt(
      [[
      \begin{<>}
        <>
      \end{<>}
      <>
      ]],
      { i(1, 'equation'), i(2), rep(1), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s( -- 'dm'
    'dm',
    fmt(
      [[
      \begin{equation}
              <>
      \end{equation}
      <>
      ]],
      { i(1), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin * -math }
  ),
  s('mk', fmt([[$<>$<>]], { i(1), i(0) }, { delimiters = '<>' })),
}
