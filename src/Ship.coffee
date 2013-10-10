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
  invmass: 1

  constructor: (viewport, tree, stage, options) ->
    @posClamp = new Vector2d(0, 1024 * 16)
    @velClamp = new Vector2d(-@maxSpeed, @maxSpeed)

    super(
      new Vector2d(8196, 12135), #pos
      new Vector2d(0, 0), #vel
      32, 32 # w,h
    )

    @options = options
    @_tree = tree

    # TODO: Make asset jsons for this and other ships
    base = PIXI.BaseTexture.fromImage("assets/shared/graphics/ship#{options.ship}.png")
    @_textures = []
    for y in [0..3]
      for x in [0..9]
        @_textures.push(new PIXI.Texture(base, {x: x * 36 + 2, y: y * 36 + 2, width: 32, height: 32}))

    @_movie = new PIXI.MovieClip(@_textures)
    @_movie.width = @w
    @_movie.height = @h
    if options.player
      @_movie.anchor.x = 0.5
      @_movie.anchor.y = 0.5
      @_movie.position.x = viewport.hw
      @_movie.position.y = viewport.hh
      stage.addChild(@_movie)
    else
      tree.insert(@)

  update: ->
    texture = Math.round((@angle * @_textures.length) / (2 * Math.PI))
    i = Math.mod(texture, @_textures.length)
    @_movie.gotoAndStop(i)
    
  simulate: (keys, delta) ->
    super(delta)

    @vel.clamp(@velClamp, @velClamp)
    @pos.clamp(@posClamp, @posClamp)

    minSafeX = minSafeY = Infinity
    maxSafeX = maxSafeY = -1

    # TODO: Split into collision engine
    # Only go through collidable pairs
    # i.e. ship collide bullet, ship collide tile,
    # but not tile collide tile and not ship collide ship
    # TODO: gah the below needs pos & extent!!
    me = @extent()
    for object in @_tree.searchExpand(me, 0)
      oe = object.extent()

      if Physics.collision(me, oe)
        if object.constructor == Tile && object.index == 169
          minSafeX = Math.min(minSafeX, oe.west)
          minSafeY = Math.min(minSafeY, oe.north)
          maxSafeX = Math.max(maxSafeX, oe.east)
          maxSafeY = Math.max(maxSafeY, oe.south)

        # TODO: Where to store collision objects
        # collide = object.index < 127
        collide = !keys.noclip && object.constructor == Tile && object.index != 169

        if collide then Physics.resolve(@, object)

    # Ship must be surrounded by safezone to be considered safe
    @safe = minSafeX <= me.west &&
             minSafeY <= me.north &&
             maxSafeX >= me.east &&
             maxSafeY >= me.south

    @tx = @pos.x / 16
    @ty = @pos.y / 16

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

    @vel.addXY(
      400 * Math.sin(@angle) * delta * y,
      -400 * Math.cos(@angle) * delta * y)

    # TODO: Disable in production
    @vel.clear() if keys.fullstop

    @vel.clear() if keys.fire && @safe
