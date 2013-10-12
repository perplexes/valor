# TODO: touching pos should update extent
class Entity
  pos: new Vector2d(0,0) # Vector2d
  vel: new Vector2d(0,0) # Vector2d, per second?
  scaledV: new Vector2d(0,0)
  w: 0
  h: 0
  hw: 0
  hh: 0
  zcode: 0
  invmass: 0

  constructor: (pos, vel, w, h) ->
    @pos = pos if pos?
    @vel = vel if vel?
    @w = w
    @h = h
    @hw = w/2
    @hh = h/2
    @_extent =
      west: 0
      north: 0
      east: 0
      south: 0
    @extent()

  simulate: (delta) ->
    @scaledV.clear()
    @scaledV.add(@vel).scaleXY(delta, delta)
    @pos.add(@scaledV)
    @extent()

  # TODO: updates to pos/w/h updates extent
  extent: ->
    @_extent.west = @pos.x - @hw
    @_extent.north = @pos.y - @hh
    @_extent.east = @pos.x + @hw
    @_extent.south = @pos.y + @hh
    @_extent