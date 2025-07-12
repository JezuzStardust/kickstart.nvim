local fmt = require('luasnip.extras.fmt').fmt
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
local cond = require 'luasnip.extras.conditions'
local math = cond.make_condition(fn_math)
local tikz = cond.make_condition(fn_tikz)

-- For auto labels
local function sanitize_label(args)
  local input = args[1][1] or ''
  local replacements = {
    ['å'] = 'a',
    ['ä'] = 'a',
    ['ö'] = 'o',
    ['Å'] = 'a',
    ['Ä'] = 'a',
    ['Ö'] = 'o',
  }
  input = input:lower()
  input = input:gsub('[%z\1-\127\194-\244][\128-\191]*', function(c)
    return replacements[c] or c
  end)
  input = input:gsub('[^%w%s]', '') -- remove punctuation
  input = input:gsub('%s+', '_') -- spaces to underscores
  return input
end

-- List of LaTeX math commands to auto-prefix with "\"
local latex_math_cmds = {
  'alpha',
  'beta',
  'gamma',
  'delta',
  'epsilon',
  'zeta',
  'eta',
  'theta',
  'iota',
  'kappa',
  'lambda',
  'mu',
  'nu',
  'xi',
  'omicron',
  'pi',
  'rho',
  'sigma',
  'tau',
  'upsilon',
  'phi',
  'chi',
  'psi',
  'omega',
  'hbar',
  'infty',
  'nabla',
  'partial',
  'ell',
  'dagger',
  'cdot',
  'pi',
  'varepsilon',
  'Omega',
  'Delta',
  'hbar',
  'sin',
  'cos',
  'tan',
  'arcsin',
  'arccos',
  'arctan',
  'log',
}

-- Helper function to create the conditional snippet
local function latex_cmd_snippet(cmd)
  return s({ trig = cmd, wordTrig = true, regTrig = false }, t('\\' .. cmd), {
    condition = math * function(line_to_cursor)
      local pos = #line_to_cursor - #cmd
      return line_to_cursor:sub(pos, pos) ~= '\\'
    end,
  })
end

-- Register the snippets
local latex_cmd_auto_snippets = {}
for _, cmd in ipairs(latex_math_cmds) do
  table.insert(latex_cmd_auto_snippets, latex_cmd_snippet(cmd))
end

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

  -- Function parameters
  s(
    {
      -- Match function name + space + arguments + O
      trig = '([%a_%^][%w_]*)%s+([%w_,]+)O',
      regTrig = true,
      wordTrig = false,
    },
    fmt('{}({}){}', {
      f(function(_, snip)
        return snip.captures[1] -- function name (e.g. f)
      end, {}),
      f(function(_, snip)
        local raw = snip.captures[2] -- args like "x,y,z"
        local parts = {}
        for token in string.gmatch(raw, '[^,]+') do
          table.insert(parts, vim.trim(token))
        end
        return table.concat(parts, ', ')
      end, {}),
      i(1),
    }),
    { condition = math }
  ),
  -- s(
  --   { trig = '([%w_,]+)O', regTrig = true, wordTrig = false },
  --   fmt('({}){}', {
  --     f(function(_, snip)
  --       local raw = snip.captures[1]
  --       local parts = {}
  --
  --       for token in string.gmatch(raw, '[^,]+') do
  --         table.insert(parts, vim.trim(token))
  --       end
  --
  --       return table.concat(parts, ', ')
  --     end, {}),
  --     i(0),
  --   })
  -- ),
  s({ trig = '()', wordTrig = false }, fmt([[\left( <> \right)<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('[]', fmt([[\left[ <> \right]<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('lr{', fmt([[\left\{ <> \right\}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('lr|', fmt([[\left| <> \right|<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('lr<', fmt([[\left< {} \right>{}]], { i(1), i(0) }, { delimiters = '{}' }), { condition = math }),
  -- Integral
  -- Sum
  -- Limit
  -- Set
  -- Subscript, superscript, subtext, supertext, hat, hat as written
  -- Frac (2 versions)
  s(
    {
      trig = '([%w_\\%^%{%}]+)/',
      regTrig = true,
      wordTrig = false,
    },
    fmt([[\frac{<>}{<>}<>]], {
      f(function(_, snip)
        return snip.captures[1]
      end, {}),
      i(1),
      i(0),
    }, { delimiters = '<>' }),
    { condition = math }
  ),
  -- s(
  --   { trig = '%s([^%s]+)/', regTrig = true },
  --   fmt([[\frac{<>}{<>}<>]], {
  --     f(function(_, snip)
  --       return snip.captures[1]
  --     end, {}),
  --     i(1),
  --     i(0),
  --   }, { delimiters = '<>' }),
  --   { condition = math }
  -- ),
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
  s(
    { trig = 'b(%d)(%d)', regTrig = true },
    f(function(_, snip)
      return 'Captured Text: ' .. snip.captures[1] .. snip.captures[2] .. '.'
    end, {})
  ), -- Chapter, section,
  s(
    { trig = 'ch' },
    fmt(
      [[
      \chapter{<>}
      \label{sec:<>}

      <>
      ]],
      { i(1, 'title'), f(sanitize_label, { 1 }), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'sc' },
    fmt(
      [[
      \section{<>}
      \label{sec:<>}

      <>
      ]],
      { i(1, 'title'), f(sanitize_label, { 1 }), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'sub' },
    fmt(
      [[
      \subsection{<>}
      \label{sec:<>}

      <>
      ]],
      { i(1, 'title'), f(sanitize_label, { 1 }), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'ssub' },
    fmt(
      [[
      \subsubsection{<>}
      \label{sec:<>}

      <>
      ]],
      { i(1, 'title'), f(sanitize_label, { 1 }), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  -- Unpack snippets generated above.
  unpack(latex_cmd_auto_snippets),
}
