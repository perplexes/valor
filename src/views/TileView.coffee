View = require './View'
PIXI = require '../../vendor/pixi-1.5.2.dev.js'
BMPImage = require '../../vendor/bmpimage/bmpimage2.js'
Asset = require './Asset'

# TODO: Should Asset handle PIXI texture stuff?
class TileView extends View
  View.extended(@, "Map")

  @spriteMapWidth = 19 # in tiles
  @spriteMapHeight = 10 # in tiles
  baseTexture = null
  @textures = []

  constructor: (tile) ->
    return super(tile) unless texture = @constructor.textures[tile.index]

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

    asset = Asset.load(
      "tiles",
      304, 160,
      @spriteMapHeight, @spriteMapWidth,
      null,
      new PIXI.BaseTexture(canvas))

    @textures = asset.textures

module.exports = TileView