Vector2d = require("./Vector2d")
Extent = require("./Extent")
Physics = require("./Physics")

# TODO: touching pos should update extent
class Entity
  entityMap = {}

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
    @init(simulator, pos, vel, w, h)

  init: (simulator, pos, vel, w, h) ->
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

    # Trigger after-initialize
    @sync({})

  resize: (w, h) ->
    @init(@simulator, @pos, @vel, w, h)

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
  expireNow: ->
    @lifetime = 0
    # TODO: This should happen in the game loop
    @simulator.remove(@) if @simulator?
    delete @simulator if @simulator?

  onExpire: ->
    

  alive: ->
    # There's no timer on this
    return true if @lifetime == null
    @lifetime > 0

  serialize: (obj) ->
    obj.pos = @pos
    obj.vel = @vel
    obj.w = @w
    obj.h = @h
    obj.hash = @hash
    obj.klass = @constructor.name
    obj

  diff = new Vector2d
  sync: (obj) ->
    for key, value of obj
      # Smooth positional updates
      # Derivatives are better to update in jumps
      if key == "pos"
        diff.clear().add(@pos).sub(value)
        distance = diff.length()

        if distance > 2
          @pos.clear().add(value)
        else if distance > 0.1
          diff.scaleXX(0.1)
          @pos.add(diff)

      else if key == "vel"
        @vel.x = value.x
        @vel.y = value.y
      else
        @[key] = value

  @deserialize: (game, obj) ->
    entity = new entityMap[obj.klass]()
    entity.simulator = game.simulator
    entity.sync(obj)
    entity.simulator.insert(entity)
    entity.extent()
    entity

  @extended: (klass) ->
    entityMap[klass.name] = klass

module.exports = Entity
