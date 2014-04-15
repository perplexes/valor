class Asset
  @assets = {}

  # TODO: Should this be cols, rows instead?
  @load: (name, width, height, rows, cols, path = null, baseTexture = null) ->
    return @assets[name] if @assets[name]

    baseTexture ||= PIXI.BaseTexture.fromImage(path)
    baseTexture.width = width
    baseTexture.height = height
    tWidth = width / cols
    tHeight = height / rows
    textures = []
    for y in [0..rows-1]
      for x in [0..cols-1]
        textures.push(new PIXI.Texture(baseTexture, {x: x*tWidth, y: y*tHeight, width: tWidth, height: tHeight}))

    @assets[name] = {w: width, h: height, textures: textures}

  @movie: (name, speed, looop, play, textures) ->
    asset = @assets[name]
    unless asset
      throw "Unknown asset: #{name}"
    textures ||= asset.textures
    movie = new PIXI.MovieClip(textures)
    movie.width = asset.w
    movie.height = asset.w
    movie.anchor.x = 0.5
    movie.anchor.y = 0.5
    movie.animationSpeed = speed
    movie.loop = looop
    movie.play() if play
    movie

  @preload: ->
    @load("explode0", 112, 16, 1, 7, "assets/shared/graphics/explode0.png")
    @load("explode1", 288, 288, 6, 6, "assets/shared/graphics/explode1.png")
    @load("bullets", 20, 50, 10, 4, "assets/shared/graphics/bullets.png")
    @load("ship0", 360, 144, 4, 10, "assets/shared/graphics/ship0.png")
    @load("ship1", 360, 144, 4, 10, "assets/shared/graphics/ship1.png")