Entity = require("./Entity")
Vector2d = require("./Vector2d")
Bullet = require("./Bullet")
Effect = require("./Effect")
Extent = require("./Extent")
Tile = require("./Tile")

# Use a mod that can deal with negative numbers
`Math.mod = function(a,b) {
    var r = a % b;
    var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r+b) : -Math.mod(-a,-b));

    return m === b ? 0 : m;
  }
`

class Ship extends Entity
  Entity.extended(@)

  rawAngle: 0
  angle: 0
  safe: false
  maxSpeed: 500 # pixels / second
  maxEnergy: 1000
  noclip: false # TODO: Does setting this true mean it's shared across instances??
  # TODO: advanceTime with listeners for managing timers and stuff
  # Or, have global absolute time
  gunTimeoutDefault: 0.5
  gunTimeout: 0
  energy: @::maxEnergy
  # Bullets
  fireEnergy: 20
  locations:
    nearSafe: [8136, 11428],
    touchSafe: [8136, 11784],
    circles: [513 * 16, 397 * 16]
    weirdText: [5614, 743]

  # TODO: Follow unreal role/field replication strategy
  serialize: ->
    super
      angle: @angle,
      maxSpeed: @maxSpeed,
      maxEnergy: @maxEnergy,
      gunTimeoutDefault: @gunTimeoutDefault,
      gunTimeout: @gunTimeout,
      energy: @energy,
      fireEnergy: @fireEnergy,
      options: @options

  constructor: (simulator, player = false, options = {}) ->
    loc = @locations[options.location] || @locations.nearSafe
    pos = null
    if options.pos
      pos = options.pos 
    else
      pos = Vector2d.array(loc)

    super(
      simulator,
      pos,
      new Vector2d(0, 0), #vel
      32, 32 # w,h
    )

    @player = player
    @options = options

  simulate: (delta_s) ->
    @vel.clamp(@velClamp)

    @gunTimeout -= delta_s if @gunTimeout > 0

    super(delta_s)

    @safe = @safety.surrounds(@_extent)

    if @safe
      for bullet in @bullets
        bullet.expire() if bullet.lifetime > 0
      @bullets = []

    @safety.reset()

    @pos.clamp(@posClamp)

    @tx = @pos.x / 16
    @ty = @pos.y / 16

  collide: (entity) ->
    return unless entity.constructor == Tile

    if entity.index == 170
      @safety.minmax(entity._extent)

    # TODO: Where to store collision objects
    # collide = entity.index < 127
    super(entity) if !@noclip && entity.index != 170
  
  # Process? Apply?
  processInput: (ev, simulator) ->
    # In increments of how many textures there are.
    @rawAngle += 0.7 * ev.x
    @angle = (Math.round(@rawAngle * 40) / 40) * Math.PI * 2

    # 400 .. pixels per second
    # TODO: Parameterize
    @vel.addPolar(400 * ev.y, @angle)

    if ev.fire > 0
      if @safe
        @vel.clear()
      else if @gunTimeout <= 0 && @energy >= @fireEnergy
        @energy -= @fireEnergy
        # TODO: we're leaking objects here unless they go to safety
        # Maybe have a list of parents that retain this object
        @bullets.push(new Bullet(@, simulator, 2, true))
        @gunTimeout = @gunTimeoutDefault

    # @noclip = keys.noclip > 0

  onDamage: (projectile, damage) ->
    return unless @alive()
    return if @safe
    # TODO: Damage from explosions nearby
    @energy -= damage
    if @energy <= 0
      # TODO: Under server authority
      @explode()

  alive: ->
    return false if @energy <= 0
    super()

  explode: ->
    @expire()
    Effect.create('explode1', @pos, @vel)

  sync: (obj) ->
    super(obj)

    # TODO: Parameter based on map
    @posClamp = new Vector2d(0, 1024 * 16)
    # TODO: After init/resync on replication
    @velClamp = new Vector2d(-@maxSpeed, @maxSpeed)
    @gunTimeout = @gunTimeoutDefault
    @safety = new Extent(Infinity, Infinity, -1, -1)
    @energy = @maxEnergy
    @bullets = []


module.exports = Ship