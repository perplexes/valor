# Should be named point?
class Vector2d
  constructor: (x, y) ->
    @x = x || 0
    @y = y || 0
    @__x = @x
    @__y = @y

  # Set to initial values. Usually 0.
  # TODO: Might not be performant. (More accesses than just x = y = 0)
  clear: ->
    @x = @y = 0
    @

  reset: ->
    @x = @__x
    @y = @__y
    @

  add: (v) ->
    debugger if typeof v == 'undefined'
    debugger if arguments.length != 1
    @addXY(v.x, v.y)

  addPolar: (r, theta) ->
    debugger if r == NaN
    debugger if theta == NaN
    debugger if arguments.length != 2
    debugger if typeof r != 'number'
    debugger if typeof theta != 'number'
    @addXY(r * Math.sin(theta), r * -Math.cos(theta))

  addXY: (x, y) ->
    debugger if x == NaN
    debugger if y == NaN
    debugger if arguments.length != 2
    debugger if typeof x != 'number'
    debugger if typeof y != 'number'
    @x += x
    @y += y
    @

  sub: (v) ->
    debugger if typeof v == 'undefined'
    debugger if arguments.length != 1
    @addXY(-v.x, -v.y)
    @

  subXY: (x, y) ->
    @addXY(-x, -y)
    @

  dot: (v) ->
    debugger if arguments.length != 1
    debugger if typeof v == 'undefined'
    debugger if typeof v.x != 'number'
    debugger if typeof v.y != 'number'
    @x * v.x + @y * v.y

  scale: (v) ->
    debugger if typeof v == 'undefined'
    debugger if arguments.length != 1
    @scaleXY(v.x, v.y)
    @

  scaleXY: (x, y) ->
    debugger if arguments.length != 2
    debugger if typeof x != 'number'
    debugger if typeof y != 'number'
    debugger if x == NaN
    debugger if y == NaN
    @x *= x
    @y *= y
    @

  scaleXX: (x) ->
    @scaleXY(x, x)
    @

  lshift: (power) ->
    @x <<= power
    @y <<= power
    @

  # Unsigned
  rshift: (power) ->
    @x >>>= power
    @y >>>= power
    @

  clamp: (clamp) ->
    @clamp4(clamp.x, clamp.y, clamp.x, clamp.y)
    @

  clamp4: (x1, x2, y1, y2) ->
    debugger if x1 == NaN
    debugger if y1 == NaN
    debugger if x2 == NaN
    debugger if y2 == NaN
    debugger if typeof x1 != 'number'
    debugger if typeof x2 != 'number'
    debugger if typeof y1 != 'number'
    debugger if typeof y2 != 'number'
    @x = @x.clamp(x1, x2)
    @y = @y.clamp(y1, y2)
    @
