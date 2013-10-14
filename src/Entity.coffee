# TODO: touching pos should update extent
class Entity
  layer: null
  simulator: null
  pos: new Vector2d(0,0) # Vector2d
  vel: new Vector2d(0,0) # Vector2d, per second?
  scaledV: new Vector2d(0,0)
  w: 0
  h: 0
  hw: 0
  hh: 0
  zcode: 0
  invmass: 1
  _sceneNode: null
  _displayObject: null
  hash: 0
  objectCounter = 0
  lifetime: null
  maxSpeed: null
  bounciness: 0.5
  friction: 0.8

  constructor: (layer, simulator, pos, vel, w, h) ->
    @layer = layer if layer?
    @simulator = simulator if simulator?
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

    @layer.insert(@) if @layer?
    @simulator.addObject(@) if @simulator?

    @hash = (objectCounter += 1)

  simulate: (delta) ->
    # TODO: Better place for this?
    if @lifetime
      if @lifetime <= 0
        @layer.remove(@) if @layer?
        @simulator.removeObject(@) if @simulator?
        return
      else
        @lifetime -= delta

    @scaledV.clear()
    @scaledV.add(@vel).scaleXY(delta, delta)
    @layer.remove(@)
    @pos.add(@scaledV)
    @layer.insert(@)
    @extent()

  collide: (entity) ->
    Physics.resolve(@, entity)

  update: ->
    return unless @_displayObject
    @_displayObject.position.x = @pos.x - @layer.scene.viewport._extent.west
    @_displayObject.position.y = @pos.y - @layer.scene.viewport._extent.north

  # TODO: updates to pos/w/h updates extent
  extent: ->
    @_extent.west = @pos.x - @hw
    @_extent.north = @pos.y - @hh
    @_extent.east = @pos.x + @hw
    @_extent.south = @pos.y + @hh
    @_extent

  expire: ->
    @lifetime = 0