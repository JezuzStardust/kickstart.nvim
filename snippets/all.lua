return {
  s('trig', t 'loaded!!'),
  s('snig', t 'works!'),
  s(
    'srig',
    c(1, {
      t 'Ugh boring, a text node',
      i(nil, 'At least I can edit something now...'),
      f(function(args)
        return 'Still only counts as text!!'
      end, {}),
    })
  ),
}
