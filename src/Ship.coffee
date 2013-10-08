`Math.mod = function(a,b) {
    var r = a % b;
    var m = a === 0 ? 0 : (b > 0 ? (a >= 0 ? r : r+b) : -Math.mod(-a,-b));

    return m === b ? 0 : m;
  }
`

class Ship
  rawAngle: 0
  angle: 0
  # Near circles
  # x: 513 * 16
  # y: 397 * 16
  # Safety
  x: 8196
  y: 12135
  # Outside safety
  # x: 8197
  # y: 11986
  # Weird text bug
  # x: 5614
  # y: 743
  dx: 0
  dy: 0
  w: 32
  h: 32
  safe: false

  maxSpeed: 500
  constructor: (viewport, tree, stage, options) ->
    @options = options
    @_tree = tree
    # TODO: Make asset jsons for this and other ships
    base = PIXI.BaseTexture.fromImage("assets/shared/graphics/ship#{options.ship}.png")
    @_textures = []
    for y in [0..3]
      for x in [0..9]
        @_textures.push(new PIXI.Texture(base, {x: x * 36 + 2, y: y * 36 + 2, width: 32, height: 32}))

    @_movie = new PIXI.MovieClip(@_textures)
    @_movie.width = 32
    @_movie.height = 32
    if options.player
      @_movie.anchor.x = 0.5
      @_movie.anchor.y = 0.5
      @_movie.position.x = viewport.width / 2
      @_movie.position.y = viewport.height / 2
      stage.addChild(@_movie)
    else
      tree.insert(@)

  draw: ->
    # Add/remove from tree?
    # neagtive starts at 39, 38, etc...
    texture = Math.round((@angle * @_textures.length) / (2 * Math.PI))
    i = Math.mod(texture, @_textures.length)
    @_movie.gotoAndStop(i)
    
  simulate: (delta, keys, map) ->
    collisions = []

    @x += @dx * (delta / 1000)
    @y += @dy * (delta / 1000)
    @x = @x.clamp(0, 1024 * 16)
    @y = @y.clamp(0, 1024 * 16)
    
    @min =
      x: @x - @w/2
      y: @y - @h/2
    @max =
      x: @x + @w/2
      y: @y + @h/2

    minSafeX = minSafeY = Infinity
    maxSafeX = maxSafeY = -1

    x1 = @min.x - map.spriteWidth
    y1 = @min.y - map.spriteHeight
    x2 = @max.x + map.spriteWidth
    y2 = @max.y + map.spriteHeight

    for object in @_tree.search(x1, y1, x2, y2)
      if Physics.collision(@, object)
        collisions.push object
        if object.index == 169
          minSafeX = Math.min(minSafeX, tile.min.x)
          minSafeY = Math.min(minSafeY, tile.min.y)
          maxSafeX = Math.max(maxSafeX, tile.max.x)
          maxSafeY = Math.max(maxSafeY, tile.max.y)

        # TODO: Where to store collision tiles
        # collide = tile.index < 127
        collide = !keys.noclip && tile.index != 169

        if collide && m = Physics.overlap(@, tile)
          if resolution = Physics.resolve(@, tile, m)
            @x += resolution.a[0]
            @y += resolution.a[1]
            @dx += resolution.a[2]
            @dy += resolution.a[3]

    # Ship must be surrounded by safezone to be considered safe
    @safe = minSafeX <= @min.x &&
             minSafeY <= @min.y &&
             maxSafeX >= @max.x &&
             maxSafeY >= @max.y

    # if collisions.length > 0
    #   for tile in collisions

    #       # Skip b resolution for now - tiles are immovable

    @tx = @x / 16
    @ty = @y / 16

    collisions