local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local extras = require 'luasnip.extras'
local rep = extras.rep
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta

local line_begin = require('luasnip.extras.expand_conditions').line_begin
-- require 'luasnip.extras.conditions.expand.line_begin'
local function fn_math()
  -- Assuming vimtex is installed and available
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
function fn_si_unit()
  return vim.fn['vimtex#syntax#in'] 'texSIArgUnit' == 1
end
-- Fix this or just use the construct above.
local function fn_is_in(name)
  return vim.eval('vimtex#syntax#in("' + name + '")') == '1'
end
local function fn_env(name)
  x, y = vim.eval("vimtex#env#is_inside('" + name + "')")
  return x ~= '0' and y ~= '0'
end
local conds = require 'luasnip.extras.conditions'
local tikz = conds.make_condition(fn_tikz)
local math = conds.make_condition(fn_math)
local siunit = conds.make_condition(fn_si_unit)

-- For auto labels of chapter, section, subsection and subsubsection.
local function sanitize_label(args)
  local input = args[1][1] or ''
  local replacements = { -- Replace Swedish letters.
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
  'varphi',
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
  'maketitle',
  'tableofcontents',
  'to',
  'dots',
  'times',
}

-- Helper function to create the conditional snippet
local function latex_cmd_snippet(cmd)
  return s({ trig = cmd, wordTrig = true, regTrig = false, snippetType = 'autosnippet' }, t('\\' .. cmd), {
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

return { -- Manual snippets
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
}, { -- Autosnippets
  -- Math symbols
  s({ trig = 'inf', name = 'Infinity symbol' }, { t '\\infty' }, { condition = math }),
  s({ trig = 'gg', name = 'Much greater than' }, { t '\\gg' }, { condition = math }),
  s({ trig = '<=', name = 'Less or equal to' }, { t '\\leq' }, { condition = math }),
  s({ trig = '>=', name = 'Greater or equal to' }, { t '\\geq' }, { condition = math }),
  s({ trig = 'll', name = 'Much less than' }, { t '\\ll' }, { condition = math }),
  s('DD', { t '\\Delta' }, { condition = math }),
  s('xx', { t '\\times' }, { condition = math }),
  s('imp', { t '\\implies' }, { condition = math }),
  s('pp', { t '\\partial' }, { condition = math }),
  s('...', { t '\\dots' }, { condition = math }),
  s('==', fmt([[ &= <> \\]], { i(1) }, { delimiters = '<>' }), { condition = math }),

  -- Function parameters
  s( -- x,y,zO, tO, etc. - function parameters
    {
      trig = '([%a_%^][%w_%{%}]*)%s+([%w_,\\%{%}]+)O',
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
  -- Parenthesis
  s({ trig = '()', wordTrig = false }, fmt([[\left( <> \right)<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('lr[', fmt('\\left[ <> \\right]', { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('lr{', fmt([[\left\{ <> \right\}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('lr|', fmt([[\left| <> \right|]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('lr<', fmt([[\left< {} \right\>]], { i(1) }, { delimiters = '{}' }), { condition = math }),
  s('dot', fmt([[\dot{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('ddot', fmt([[\ddot{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('udot', fmt([[\udot{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  --  TODO: Sets
  -- Auto-indexing
  s(
    {
      trig = '([%a]+)(%d)',
      regTrig = true,
      wordTrig = true,
    },
    fmt('<>_{<>}<>', {
      f(function(_, snip)
        return snip.captures[1] -- variable
      end, {}),
      f(function(_, snip)
        return snip.captures[2] -- numeric index
      end, {}),
      i(0),
    }, { delimiters = '<>' }),
    { condition = math }
  ),
  -- Subscript
  s({ trig = 'tpo', wordTrig = false }, fmt([[^{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'tps', wordTrig = false }, t '^{*}', { condition = math }),
  s({ trig = 'trans', wordTrig = false }, t '^{\text{T}}', { condition = math }),
  s({ trig = '__', wordTrig = false }, fmt([[_{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'iot', wordTrig = false }, fmt([[_{\text{<>}}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'tpt', wordTrig = false }, fmt([[^{\text{<>}}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = '__', wordTrig = false }, fmt([[_{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'iog', wordTrig = false }, fmt([[_{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  -- Frac (2 versions)
  s(
    {
      trig = '([%w_\\%^%{%}%(%)]+)/',
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
  s({ trig = '//', wordTrig = false }, fmt([[\frac{<>}{<>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  -- Equals with alignment
  -- Left/right delimiters
  -- To the power of
  s('lim', fmt([[\lim_{<> \to <>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('sum', fmt([[\sum_{<>}^{<>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'iiint', wordTrig = false }, fmt([[\iiint_{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'voiint', wordTrig = false }, fmt([[\varoiint_{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'oint', wordTrig = false }, fmt([[\oint_{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'oiint', wordTrig = false }, fmt([[\oiint_{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'iint', wordTrig = false }, fmt([[\iint_{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'int', wordTrig = false }, fmt([[\int_{<>}^{<>}<>]], { i(1), i(2), i(0) }, { delimiters = '<>' }), { condition = math }),
  -- Square
  s({ trig = 'sr', wordTrig = false }, { t '^2' }, { condition = math }),
  -- Cubed
  s({ trig = 'cb', wordTrig = false }, { t '^3' }, { condition = math }),
  -- Square root
  s(
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
  s('vec', fmt([[\vec{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('uvec', fmt([[\uvec{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  -- bec (custom vector with hat)
  s('bec', fmt([[\bec{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  -- ubec (custom bm vector with hat)
  s('ubec', fmt([[\ubec{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('cal', fmt([[\mathcal{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('bb', fmt([[\mathbb{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('tx', fmt([[\text{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  -- TODO: Mathcal
  -- TODO: Text formatting
  -- TODO: Emph, txt, txb,
  -- TODO: SI Package
  s('SI', fmt([[\SI{<>}{<>}]], { i(1), i(2) }, { delimiters = '<>' })),
  s('ang', fmt([[\ang{<>}<>]], { i(1), i(0) }, { delimiters = '<>' }), { condition = math }),
  s('unit', fmt([[\unit{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s('num', fmt([[\num{<>}]], { i(1) }, { delimiters = '<>' }), { condition = math }),
  s({ trig = 'per', wordTrig = false }, { t '\\per' }, { condition = siunit }),
  s({ trig = 'kg', wordTrig = false }, { t '\\kilogram' }, { condition = siunit }),
  s({ trig = 'met', wordTrig = false }, { t '\\meter' }, { condition = siunit }),
  s({ trig = 'sec', wordTrig = false }, { t '\\second' }, { condition = siunit }),
  s({ trig = 'rad', wordTrig = false }, { t '\\rad' }, { condition = siunit }),
  -- TODO: Fix some of this with priority or with condition bolean.
  s({ trig = 'p2', wordTrig = false }, { t '\\squared' }, { condition = siunit }),
  s({ trig = 'p3', wordTrig = false }, { t '\\cubed' }, { condition = siunit }),
  s({ trig = 'jol', wordTrig = false }, { t '\\joule' }, { condition = siunit }),
  s({ trig = 'kil', wordTrig = false }, { t '\\kilo' }, { condition = siunit }),
  s({ trig = 'gg', wordTrig = false }, { t '\\giga' }, { condition = siunit }),
  s({ trig = 'mic', wordTrig = false }, { t '\\micro' }, { condition = siunit }),
  s({ trig = 'nan', wordTrig = false }, { t '\\nano' }, { condition = siunit }),

  -- TikZ related stuff
  -- Nodes
  -- Draw commands
  -- Plot

  -- Environments
  -- Aligned
  -- Itemize
  -- Enumerate
  s( -- 'beg - begin{} \end{}'
    'beg',
    fmt(
      [[
      \begin{<>}
        <>
      \end{<>}
      ]],
      { i(1, 'equation'), i(2), rep(1) },
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
  s( -- 'alpa'
    'alpa',
    fmt(
      [[
      \begin{equation}
        \left\{
        \begin{aligned}
          <>
        \end{aligned}
        \right.
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
  s( -- ch - chapter
    { trig = 'ch' },
    fmt(
      [[
      \chapter{<>}
      \label{ch:<>}

      <>
      ]],
      { i(1, 'title'), f(sanitize_label, { 1 }), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s( --sc - section
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
  s( --sub - subsection
    { trig = 'sub' },
    fmt(
      [[
      \subsection{<>}
      \label{sub:<>}

      <>
      ]],
      { i(1, 'title'), f(sanitize_label, { 1 }), i(0) },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s( --ssub - subsubsection
    { trig = 'ssub' },
    fmt(
      [[
      \subsubsection{<>}
      \label{ssub:<>}

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
