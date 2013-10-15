class Bullet extends Entity
  bounciness: 1
  friction: 0
  damage: 200
  base = PIXI.BaseTexture.fromImage("assets/shared/graphics/bullets.png")
  textures = []
  for y in [0..10]
    row = []
    for x in [0..3]
      row.push(new PIXI.Texture(base, {x: x*5, y: y*5, width: 5, height: 5}))
    textures.push row
  constructor: (ship, simulator, level, bouncing) ->
    @ship = ship
    @simulator = simulator
    @level = level
    @bouncing = bouncing

    @lifetime = 10

    super(
      Layer.layers['projectile'],
      simulator,
      new Vector2d(0,0).add(ship.pos).addPolar(ship.hw, ship.angle),
      new Vector2d(0,0).add(ship.vel).addPolar(100, ship.angle),
      5, 5
    )

    movieRow = level
    movieRow += 5 if bouncing

    @_movie = new PIXI.MovieClip(textures[movieRow])
    @_movie.width = @w
    @_movie.height = @h
    @_movie.anchor.x = 0.5
    @_movie.anchor.y = 0.5
    @_movie.loop = true
    @_movie.animationSpeed = 0.5
    @_movie.play()

    @_displayObject = @_movie

  collide: (object) ->
    if object.constructor == Tile
      if object.index == 170
        return
      else if @bouncing
        super(object)

    if object.constructor == Ship && object != @ship
      object.onDamage(@, @damage)
      @expire()
      Effect.create('explode0', @pos, null)

  update: ->
    if @ship.safe
      # TODO: Automatic cleanup for "lifetime"
      @layer.remove(@)
      @layer.removeChild(@)
      @simulator.removeObject(@)
    super()