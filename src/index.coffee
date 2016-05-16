app = require './app'

requireAll = (r) ->
  r.keys().forEach(r)

requireAll require.context './', true, /\.\/.+\/.+\.(coffee|html|scss|jade)$/
