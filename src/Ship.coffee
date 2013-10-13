# Use a mod that can deal with negative numbers
`Math.mod = function(a,b) {
    var r = a % b;
    var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r+b) : -Math.mod(-a,-b));

    return m === b ? 0 : m;
  }
`

class Ship extends Entity
  @_displayObjectContainer = new PIXI.DisplayObjectContainer()
  @tree = new ZTree()

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
  invmass: 1
  noclip: false # TODO: Does setting this true mean it's shared across instances??

  constructor: (scene, player, options) ->
    @posClamp = new Vector2d(0, 1024 * 16)
    @velClamp = new Vector2d(-@maxSpeed, @maxSpeed)

    super(
      scene,
      # new Vector2d(8196, 12135), # safety
      new Vector2d(8136, 11784), # Touching safety wall
      new Vector2d(0, 0), #vel
      32, 32 # w,h
    )

    @player = player
    @options = options
    @keys = options.keys

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
      @_movie.position.x = scene.viewport.hw
      @_movie.position.y = scene.viewport.hh

    @_displayObject = @_movie

  update: ->
    texture = Math.round((@angle * @_textures.length) / (2 * Math.PI))
    i = Math.mod(texture, @_textures.length)
    @_movie.gotoAndStop(i)
    super() unless @player

  simulate: (delta) ->
    super(delta)

    minSafeX = minSafeY = Infinity
    maxSafeX = maxSafeY = -1

    @pos.clamp(@posClamp, @posClamp)

    # Ship must be surrounded by safezone to be considered safe
    @safe = minSafeX <= @_extent.west &&
             minSafeY <= @_extent.north &&
             maxSafeX >= @_extent.east &&
             maxSafeY >= @_extent.south

    
    @tx = @pos.x / 16
    @ty = @pos.y / 16

  minSafeX = minSafeY = Infinity
  maxSafeX = maxSafeY = -1
  collision: (object) ->
    return unless object.constructor == Tile

    if object.index == 170
      minSafeX = Math.min(minSafeX, object._extent.west)
      minSafeY = Math.min(minSafeY, object._extent.north)
      maxSafeX = Math.max(maxSafeX, object._extent.east)
      maxSafeY = Math.max(maxSafeY, object._extent.south)

    # TODO: Where to store collision objects
    # collide = object.index < 127
    if !@noclip && object.index != 170
      Physics.resolve(@, object)

  onKeys: (keys, delta) ->
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
    @angle = (Math.round(@rawAngle * 40) / 40) * Math.PI * 2

    @vel.addPolar(400 * delta * y, @angle)
    @vel.clamp(@velClamp, @velClamp)

    # TODO: Disable in production
    @vel.clear() if keys.fullstop

    @vel.clear() if keys.fire && @safe

    @noclip = @keys.noclip
