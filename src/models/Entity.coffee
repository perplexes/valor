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

  constructor: (simulator, pos, vel, w, h) ->
    @simulator = simulator if simulator?
    @pos = pos if pos?
    @vel = vel if vel?
    @w = w
    @h = h
    @hw = hw = w/2
    @hh = hh = h/2
    @_extent = new Extent(@pos.x - hw, @pos.y - hh, @pos.x + hw, @pos.y + hh)
    @extent()

    @hash = (objectCounter += 1)
    # Simulator needs the hash
    @simulator.insert(@) if @simulator?


  simulate: (delta_s) ->
    # TODO: Better place for this?
    if @lifetime
      if @lifetime <= 0
        @expire()
        return
      else
        @lifetime -= delta_s

    if @simulator? && !@vel.isZero()
      @scaledV.clear().add(@vel).scaleXX(delta_s)
      @simulator.dynamicTree.remove(@)
      @pos.add(@scaledV)
      @simulator.dynamicTree.insert(@)
      @extent()

  # TODO: Put in the simulator instead?
  collide: (entity) ->
    Physics.resolve(@, entity)

  # TODO: updates to pos/w/h updates extent
  extent: ->
    @_extent.ul.x = @pos.x - @hw
    @_extent.ul.y = @pos.y - @hh
    @_extent.lr.x = @pos.x + @hw
    @_extent.lr.y = @pos.y + @hh
    @_extent

  # TODO: When do we put this back in the pool?
  expire: ->
    @lifetime = 0
    @simulator.remove(@) if @simulator?
    delete @simulator if @simulator?

  alive: ->
    return true if @lifetime == null
    @lifetime > 0