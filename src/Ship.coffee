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
  maxSpeed: 500
  noclip: false # TODO: Does setting this true mean it's shared across instances??
  # TODO: advanceTime with listeners for managing timers and stuff
  # Or, have global absolute time
  gunTimeoutDefault: 0.5
  gunTimeout: 0
  maxEnergy: 1000
  energy: @::maxEnergy
  # Bullets
  fireEnergy: 20
  alive: true
  safety:
    west: Infinity
    north: Infinity
    east: -1
    south: -1

  constructor: (layer, simulator, player, options) ->
    @posClamp = new Vector2d(0, 1024 * 16)
    @velClamp = new Vector2d(-@maxSpeed, @maxSpeed)

    super(
      layer,
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
    @safety =
      west: Infinity
      north: Infinity
      east: -1
      south: -1
    @energy = @maxEnergy

    # TODO: Make asset jsons for this and other ships
    base = PIXI.BaseTexture.fromImage("assets/shared/graphics/ship#{options.ship}.png")
    @_textures = []
    for y in [0..3]
      for x in [0..9]
        @_textures.push(new PIXI.Texture(base, {x: x * 36 + 2, y: y * 36 + 2, width: 32, height: 32}))

    @_movie = new PIXI.MovieClip(@_textures)
    @_movie.width = @w
    @_movie.height = @h
    @_movie.anchor.x = 0.5
    @_movie.anchor.y = 0.5

    if @player
      @_movie.position.x = layer.scene.viewport.hw
      @_movie.position.y = layer.scene.viewport.hh

    @bullets = []

    @_displayObject = @_movie

  update: ->
    # Ship must be surrounded by safezone to be considered safe
    @safe = @safety.west <= @_extent.west &&
            @safety.north <= @_extent.north &&
            @safety.east >= @_extent.east &&
            @safety.south >= @_extent.south
    @angle = (Math.round(@rawAngle * 40) / 40) * Math.PI * 2
    texture = Math.round((@angle * @_textures.length) / (2 * Math.PI))
    i = Math.mod(texture, @_textures.length)
    @_movie.gotoAndStop(i)
    super() unless @player

  simulate: (delta) ->
    @gunTimeout -= delta if @gunTimeout > 0
    @safety.west = @safety.north = Infinity
    @safety.east = @safety.south = -1

    super(delta)

    if @safe
      for bullet in @bullets
        bullet.expire() if bullet.lifetime > 0
      @bullets = []

    @pos.clamp(@posClamp, @posClamp)

    @tx = @pos.x / 16
    @ty = @pos.y / 16

  collide: (entity) ->
    return unless entity.constructor == Tile

    if entity.index == 170
      @safety.west = Math.min(@safety.west, entity._extent.west)
      @safety.north = Math.min(@safety.north, entity._extent.north)
      @safety.east = Math.max(@safety.east, entity._extent.east)
      @safety.south = Math.max(@safety.south, entity._extent.south)

    # TODO: Where to store collision objects
    # collide = entity.index < 127
    super(entity) if !@noclip && entity.index != 170
      
  onKeys: (keys, simulator, delta) ->
    # Rotation
    x = 0
    x -= 1 if keys.left
    x += 1 if keys.right 

    # Thrust
    y = 0
    y += 1 if keys.up
    y -= 1 if keys.down

    # In increments of how many textures there are.
    @rawAngle += 0.7 * delta * x

    @vel.addPolar(400 * delta * y, @angle)
    @vel.clamp(@velClamp, @velClamp)

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

    @noclip = @keys.noclip

  onDamage: (projectile, damage) ->
    return unless @alive
    # TODO: Damage from explosions nearby
    @energy -= damage
    if @energy <= 0
      @explode()

  explode: ->
    @alive = false
    @expire()
    Effect.create('explode1', @pos, @vel)
