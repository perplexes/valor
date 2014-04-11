# TODO: touching pos should update extent
class Entity
  layer: null
  simulator: null
  pos: new Vector2d(0,0) # Vector2d
  vel: new Vector2d(0,0) # Vector2d, per second?
  scaledV: new Vector2d(0,0)
  doPos: new Vector2d(0,0)
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
    @hw = hw = w/2
    @hh = hh = h/2
    @_extent = new Extent(@pos.x - hw, @pos.y - hh, @pos.x + hw, @pos.y + hh)
    @extent()

    @layer.insert(@) if @layer?
    @simulator.addObject(@) if @simulator?

    @hash = (objectCounter += 1)

  simulate: (delta) ->
    # TODO: Better place for this?
    if @lifetime
      if @lifetime <= 0
        @expire()
        return
      else
        @lifetime -= delta

    @scaledV.clear().add(@vel).scaleXX(delta)
    # TODO: Update instead of remove/insert
    @layer.remove(@)
    @pos.add(@scaledV)
    @layer.insert(@)
    @extent()

  collide: (entity) ->
    Physics.resolve(@, entity)

  update: ->
    return unless @_displayObject
    @doPos.clear().
      add(@pos).
      sub(@layer.viewport._extent.ul)
    @_displayObject.position.x = @doPos.x
    @_displayObject.position.y = @doPos.y

  # TODO: updates to pos/w/h updates extent
  extent: ->
    @_extent.ul.x = @pos.x - @hw
    @_extent.ul.y = @pos.y - @hh
    @_extent.lr.x = @pos.x + @hw
    @_extent.lr.y = @pos.y + @hh
    @_extent

  expire: ->
    @lifetime = 0
    @layer.remove(@) if @layer?
    @simulator.removeObject(@) if @simulator?