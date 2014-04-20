Vector2d = require("./Vector2d.js")

class Extent
  constructor: (x1, y1, x2, y2) ->
    @ul = new Vector2d(x1, y1)
    @lr = new Vector2d(x2, y2)

  expand: (x, y) ->
    @ul.subXY(x,y)
    @lr.addXY(x,y)
    @

  add: (extent) ->
    debugger unless extent
    @ul.add(extent.ul)
    @lr.add(extent.lr)
    @

  surrounds: (extent) ->
    @ul.x <= extent.ul.x &&
    @ul.y <= extent.ul.y &&
    @lr.x >= extent.lr.x &&
    @lr.y >= extent.lr.y

  minmax: (extent) ->
    @ul.x = Math.min(@ul.x, extent.ul.x)
    @ul.y = Math.min(@ul.y, extent.ul.y)
    @lr.x = Math.max(@lr.x, extent.lr.x)
    @lr.y = Math.max(@lr.y, extent.lr.y)
    @

  clear: ->
    @ul.clear()
    @lr.clear()
    @

  reset: ->
    @ul.reset()
    @lr.reset()
    @

module.exports = Extent