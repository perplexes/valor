View = require './View'
PIXI = require '../../vendor/pixi.js/bin/pixi.dev.js'
BMPImage = require '../../vendor/bmpimage/bmpimage2.js'
Asset = require './Asset'

# TODO: Should Asset handle PIXI texture stuff?
class TileView extends View
  View.extended(@, "Map")

  @spriteMapWidth = 19 # in tiles
  @spriteMapHeight = 10 # in tiles
  baseTexture = null
  @textures = []

  # TODO: Pool?
  constructor: (tile) ->
    displayObject = null
    if tile.index == 216
      displayObject = Asset.movie("over1", 0.5, true, true)
    else if tile.index == 217
      displayObject = Asset.movie("over2", 0.3, true, true)
      # 32x32
    else if tile.index == 219
      displayObject = Asset.movie("over4", 0.2, true, true)
      # 96x92
    else if tile.index == 220
      displayObject = Asset.movie("over5", 0.5, true, true)

    else if texture = @constructor.textures[tile.index]
      displayObject = new PIXI.Sprite(texture)

    return super(tile) unless displayObject

    displayObject.anchor.x = 0.5
    displayObject.anchor.y = 0.5

    super(tile, displayObject)

  # TODO: Should this go into asset management?
  @load: (bmpData) ->
    bmp = new BMPImage(bmpData.buffer)
    canvas = document.createElement("canvas")
    canvas.name = "tileset"
    bmp.drawToCanvas(canvas)

    asset = Asset.load(
      "tiles",
      304, 160,
      @spriteMapHeight, @spriteMapWidth,
      null,
      new PIXI.BaseTexture(canvas))

    @textures = asset.textures

module.exports = TileView
