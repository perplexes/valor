# Should be named point?
class Vector2d
  constructor: (x, y) ->
    debugger if typeof x != 'number'
    debugger if typeof y != 'number'
    @x = x
    @y = y

  clear: ->
    @x = @y = 0
    @

  add: (v) ->
    debugger if typeof v == 'undefined'
    debugger if arguments.length != 1
    @addXY(v.x, v.y)

  addPolar: (r, theta) ->
    @addXY(r * Math.sin(theta), r * -Math.cos(theta))

  addXY: (x, y) ->
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

  scaleXY: (x, y) ->
    @x *= x
    @y *= y
    @

  clamp: (xv, yv) ->
    debugger if typeof xv == 'undefined'
    debugger if typeof yv == 'undefined'
    debugger if arguments.length != 2
    @clampXY(xv.x, xv.y, yv.x, yv.y)

  clampXY: (x1, x2, y1, y2) ->
    debugger if typeof x1 != 'number'
    debugger if typeof x2 != 'number'
    debugger if typeof y1 != 'number'
    debugger if typeof y2 != 'number'
    @x = @x.clamp(x1, x2)
    @y = @y.clamp(y1, y2)
    @
