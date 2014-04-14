# Use a mod that can deal with negative numbers
`Math.mod = function(a,b) {
    var r = a % b;
    var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r+b) : -Math.mod(-a,-b));

    return m === b ? 0 : m;
  }
`

class Ship extends Entity
  rawAngle: 0
  angle: 0
  # Near circles
  # x: 513 * 16
  # y: 397 * 16
  # Safety
  # x: 8196
  # y: 12135
  # Outside safety
  # x: 8197
  # y: 11986
  # Weird text bug
  # x: 5614
  # y: 743
  safe: false
  maxSpeed: 500 # pixels / second
  noclip: false # TODO: Does setting this true mean it's shared across instances??
  # TODO: advanceTime with listeners for managing timers and stuff
  # Or, have global absolute time
  gunTimeoutDefault: 0.5
  gunTimeout: 0
  maxEnergy: 1000
  energy: @::maxEnergy
  # Bullets
  fireEnergy: 20

  constructor: (simulator, player, options) ->
    @posClamp = new Vector2d(0, 1024 * 16)
    @velClamp = new Vector2d(-@maxSpeed, @maxSpeed)

    super(
      simulator,
      # new Vector2d(8196, 12135), # safety
      # new Vector2d(8136, 11784), # Touching safety wall
      new Vector2d(8136, 11428),
      new Vector2d(0, 0), #vel
      32, 32 # w,h
    )

    @player = player
    @options = options
    @keys = options.keys
    @gunTimeout = @gunTimeoutDefault
    @safety = new Extent(Infinity, Infinity, -1, -1)
    @energy = @maxEnergy
    @bullets = []

  simulate: (delta) ->
    @vel.clamp(@velClamp)

    @gunTimeout -= delta if @gunTimeout > 0

    # Ship must be surrounded by safezone to be considered safe
    @angle = (Math.round(@rawAngle * 40) / 40) * Math.PI * 2

    super(delta)

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
      
  onKeys: (keys, simulator, delta_s) ->
    # Rotation
    x = 0
    x -= 1 if keys.left
    x += 1 if keys.right 

    # Thrust
    y = 0
    y += 1 if keys.up
    y -= 1 if keys.down

    # In increments of how many textures there are.
    @rawAngle += 0.7 * delta_s * x

    # 400 .. pixels per second
    # TODO: Parameterize
    @vel.addPolar(400 * delta_s * y, @angle)

    # TODO: Disable in production
    @vel.clear() if keys.fullstop

    if keys.fire
      if @safe
        @vel.clear()
      else if @gunTimeout <= 0 && @energy >= @fireEnergy
        @energy -= @fireEnergy
        # TODO: we're leaking objects here unless they go to safety
        # Maybe have a list of parents that retain this object
        @bullets.push(new Bullet(@, simulator, 2, true))
        @gunTimeout = @gunTimeoutDefault

    @noclip = keys.noclip

  onDamage: (projectile, damage) ->
    return unless @alive()
    return if @safe
    # TODO: Damage from explosions nearby
    @energy -= damage
    if @energy <= 0
      @explode()

  alive: ->
    return false if @energy <= 0
    super()

  explode: ->
    @expire()
    Effect.create('explode1', @pos, @vel)
