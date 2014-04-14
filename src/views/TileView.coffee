class TileView extends View
  @spriteMapWidth = 19 # in tiles
  @spriteMapHeight = 10 # in tiles
  baseTexture = null
  textures = []

  constructor: (tile) ->
    return unless texture = Effect.effects[tile.index]

    # TODO: pool
    displayObject = new PIXI.Sprite(texture)
    displayObject.anchor.x = 0.5
    displayObject.anchor.y = 0.5

    super(tile, displayObject)

  # TODO: Should this go into asset management?
  @load: (bmpData) ->
    bmp = new BMPImage(bmpData.buffer)
    canvas = document.createElement("canvas")
    canvas.name = "tileset"
    bmp.drawToCanvas(canvas)

    Effect.load(
      "tiles",
      304, 160,
      @spriteMapHeight, @spriteMapWidth,
      null, new PIXI.BaseTexture(canvas))