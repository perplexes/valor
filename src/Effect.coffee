class Effect extends Entity
  effects = {}
  @load: (name, asset, width, height, rows, cols) ->
    base = PIXI.BaseTexture.fromImage(asset)
    base.width = width
    base.height = height
    tWidth = width / cols
    tHeight = height / rows
    textures = []
    for y in [0..rows-1]
      for x in [0..cols-1]
        textures.push(new PIXI.Texture(base, {x: x*tWidth, y: y*tHeight, width: tWidth, height: tHeight}))

    effects[name] = textures

  @load("explode0", "assets/shared/graphics/explode0.png", 112, 16, 1, 7)
  @load("explode1", "assets/shared/graphics/explode1.png", 288, 288, 6, 6)

  constructor: (textures, pos, vel) ->
    @movie = new PIXI.MovieClip(textures)
    @movie.width = 16
    @movie.height = 16
    @movie.anchor.x = 0.5
    @movie.anchor.y = 0.5
    @movie.animationSpeed = 0.5
    @movie.onComplete = => @expire()
    @movie.loop = false
    @movie.play()

    super(
      Layer.layers['effects'],
      Simulator.simulator,
      pos,
      vel,
      @movie.width,
      @movie.height
    )

    @_displayObject = @movie


  @create: (name, pos, vel) ->
    new Effect(effects[name], pos, vel)

  collide: -> # No op