# TODO: touching pos should update extent
class Entity
  scene: null
  pos: new Vector2d(0,0) # Vector2d
  vel: new Vector2d(0,0) # Vector2d, per second?
  scaledV: new Vector2d(0,0)
  w: 0
  h: 0
  hw: 0
  hh: 0
  zcode: 0
  invmass: 0
  _sceneNode: null
  _displayObject: null
  hash: 0
  objectCounter = 0

  constructor: (scene, pos, vel, w, h) ->
    @scene = scene if scene?
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

    @constructor.tree.insert(@) if @constructor.tree
    @hash = (objectCounter += 1)

  simulate: (delta) ->
    @scaledV.clear()
    @scaledV.add(@vel).scaleXY(delta, delta)
    @constructor.tree.remove(@)
    @pos.add(@scaledV)
    @constructor.tree.insert(@)
    @extent()

  update: ->
    return unless @_displayObject
    @_displayObject.position.x = @pos.x - @scene.viewport._extent.west
    @_displayObject.position.y = @pos.y - @scene.viewport._extent.north

  # TODO: updates to pos/w/h updates extent
  extent: ->
    @_extent.west = @pos.x - @hw
    @_extent.north = @pos.y - @hh
    @_extent.east = @pos.x + @hw
    @_extent.south = @pos.y + @hh
    @_extent