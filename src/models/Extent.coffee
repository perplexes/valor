Vector2d = require("./Vector2d")

class Extent
  constructor: (x1, y1, x2, y2) ->
    @ul = new Vector2d(x1, y1)
    @lr = new Vector2d(x2, y2)
    @update()

  expand: (x, y) ->
    @ul.subXY(x,y)
    @lr.addXY(x,y)
    @update()
    @

  add: (extent) ->
    debugger unless extent
    @ul.add(extent.ul)
    @lr.add(extent.lr)
    @update()
    @

  surrounds: (extent) ->
    @ul.x <= extent.ul.x &&
    @ul.y <= extent.ul.y &&
    @lr.x >= extent.lr.x &&
    @lr.y >= extent.lr.y

  # In rbush this is called "extend"
  minmax: (extent) ->
    @ul.x = Math.min(@ul.x, extent.ul.x)
    @ul.y = Math.min(@ul.y, extent.ul.y)
    @lr.x = Math.max(@lr.x, extent.lr.x)
    @lr.y = Math.max(@lr.y, extent.lr.y)
    @update()
    @

  # Pretend I am an array!
  # TODO: Fix rbush to not use arrays
  # or have zero-allocate arrays everywhere
  update: ->
    this[0] = @ul.x
    this[1] = @ul.y
    this[2] = @lr.x
    this[3] = @lr.y

  # Set to 0
  clear: ->
    @ul.clear()
    @lr.clear()
    @update()
    @

  # Set to original value
  reset: ->
    @ul.reset()
    @lr.reset()
    @update()
    @

module.exports = Extent
