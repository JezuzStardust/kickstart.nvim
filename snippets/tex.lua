require 'luasnip.extras.fmt'
local line_begin = require('luasnip.extras.conditions.expand').line_begin
-- require 'luasnip.extras.conditions.expand.line_begin'
local function fn_math()
  -- Assuming vimtex is installed and available
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
local function fn_tikz()
  return vim.eval('vimtex#syntax#in("' + name + '")') == '1'
end
local function fn_env(name)
  x, y = vim.eval("vimtex#env#is_inside('" + name + "')")
  return x ~= '0' and y ~= '0'
end
local math = require('luasnip.extras.conditions').make_condition(fn_math)
local tikz = require('luasnip.extras.conditions').make_condition(fn_tikz)

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
  -- Math variables
  s('alpha', { t '\\alpha' }, { condition = math }),
  s('beta', { t '\\beta' }, { condition = math }),
  s('chi', { t '\\chi' }, { condition = math }),
  s('delta', { t '\\delta' }, { condition = math }),
  s('epsilon', { t '\\epsion' }, { condition = math }),
  s('gamma', { t '\\gamma' }, { condition = math }),
  s('lambda', { t '\\lambda' }, { condition = math }),
  s('omega', { t '\\omega' }, { condition = math }),
  s('psi', { t '\\psi' }, { condition = math }),
  s('rho', { t '\\rho' }, { condition = math }),
  s('sigma', { t '\\sigma' }, { condition = math }),
  s('theta', { t '\\theta' }, { condition = math }),
  s('xi', { t '\\xi' }, { condition = math }),
  s('zeta', { t '\\zeta' }, { condition = math }),

  s('pi', { t '\\pi' }, { condition = math }),
  s('hbar', { t '\\hbar' }, { condition = math }),

  -- Math symbols
  s('inf', { t '\\infty' }, { condition = math }),
  s('gg', { t '\\gg' }, { condition = math }),
  s('<=', { t '\\leq' }, { condition = math }),
  s('>=', { t '\\geq' }, { condition = math }),
  s('ll', { t '\\ll' }, { condition = math }),
  s('DD', { t '\\Delta' }, { condition = math }),
  s('xx', { t '\\cross' }, { condition = math }),
  s('cdot', { t '\\cdot' }, { condition = math }),
  s('nabla', { t '\\nabla' }, { condition = math }),
  s('imp', { t '\\implies' }, { condition = math }),
  s('to', { t '\\to' }, { condition = math }),

  -- Math functions
  s('sin', { t '\\sin' }, { condition = math }),
  s('cos', { t '\\cos' }, { condition = math }),
  s('tan', { t '\\tan' }, { condition = math }),
  s('arcsin', { t '\\arcsin' }, { condition = math }),
  s('arccos', { t '\\arccos' }, { condition = math }),
  s('arctan', { t '\\arctan' }, { condition = math }),
  s('log', { t '\\log' }, { condition = math }), -- Needs look behind!

  -- Function parameters
  s({ trig = 'ox', wordTrig = false }, { t '(x)' }, { condition = math }),
  s({ trig = 'oy', wordTrig = false }, { t '(y)' }, { condition = math }),
  s({ trig = 'oz', wordTrig = false }, { t '(z)' }, { condition = math }),
  s({ trig = 'ot', wordTrig = false }, { t '(t)' }, { condition = math }),
  s({ trig = 'lo', wordTrig = false }, fmt([[(<>,<>)<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'ko', wordTrig = false }, fmt([[(<>,<>,<>)<>]], { i(1), i(2), i(3), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'O', wordTrig = false }, fmt([[(<>)<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('()', fmt([[\left( <> \right)<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('[]', fmt([[\left[ <> \right]<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('lr{', fmt([[\left\{ <> \right\}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  -- Integral
  -- Sum
  -- Limit
  -- Set
  -- Subscript, superscript, subtext, supertext, hat, hat as written
  -- Frac (2 versions)
  -- Auto subscript?
  -- Equals with alignment
  -- Left/right delimiters
  -- To the power of
  s('lim', fmt([[\lim_{<> \to <>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('sum', fmt([[\sum_{<>}^{<>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = '//', wordTrig = false }, fmt([[\frac{<>}{<>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'int', wordTrig = false }, fmt([[\int_{<>}^{<>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s( -- Square
    { trig = 'sr', wordTrig = false },
    { t '^2' },
    { condition = math }
  ),
  s( -- Cubed
    { trig = 'cb', wordTrig = false },
    { t '^3' },
    { condition = math }
  ),
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

  -- Math formatting
  s('mb', fmt([[\mathbf{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('bm', fmt([[\bm{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('hat', fmt([[\hat{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('hmb', fmt([[\hat{\mathbf{<>}}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('hbm', fmt([[\hat{\bm{<>}}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('cc', fmt([[\mathcal{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('bb', fmt([[\mathbb{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  -- HBF
  -- Mathcal

  -- Text formatting
  -- Emph, txt, txb,
  -- SI Package
  s('ang', fmt([[\ang{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),

  -- TikZ related stuff
  -- Nodes
  -- Draw commands
  -- Plot

  -- Environments
  -- Aligned
  -- Itemize
  -- Enumerate
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
  -- Figure
  -- Chapter, section,
}
