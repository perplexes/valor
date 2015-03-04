PIXI = require '../../vendor/pixi.js/bin/pixi.dev.js'

# TODO: Use RenderTexture?
class Starfield
  LEVELS = 6
  constructor: (container, viewport) ->
    @container = container
    @viewport = viewport
    @tilesize = 1024 * 2
    @density = 32 * 4
    @levels = [
      @generateTile(2, [184,184,184]),
      @generateTile(3, [96,96,96]),
      @generateTile(4, [52,52,52]),
      @generateTile(5, [30,30,30]),
      @generateTile(6, [19,19,19])
    ]

    for level in @levels
      @container.addChild(level._displayObject)
    
  generateTile: (ratio, color) ->
    buffer = document.createElement('canvas')
    buffer.width = @tilesize
    buffer.height = @tilesize
    # buffer.style.zIndex = 1000
    # buffer.style.top = 0
    # buffer.style.position = 'absolute'
    # buffer.id = "tile#{ratio}"
    # document.body.appendChild(buffer)
    ctx = buffer.getContext('2d')
    ctx.webkitImageSmoothingEnabled = false
    # ctx.save()
    # ctx.fillStyle = 'black'
    # ctx.fillRect(0,0,1024,1024)
    # ctx.restore()
    # TODO: We want less stars in the foreground, more in background
    points = for i in [0...(@density * (Math.pow(ratio, 2)))]
      x = Math.random() * @tilesize
      y = Math.random() * @tilesize
      id = ctx.createImageData(1,1)
      d = id.data
      d[0] = color[0]
      d[1] = color[1]
      d[2] = color[2]
      d[3] = 255
      ctx.putImageData(id, x, y)
      [x, y]

    texture = PIXI.Texture.fromCanvas(buffer)
    sprite = new PIXI.TilingSprite(texture, @viewport.w, @viewport.h)

    {
      _texture: texture,
      _displayObject: sprite,
      points: points,
      color: color,
      ratio: ratio
    }

  update: ->
    @updateLevel(level) for level in @levels

  # TODO: Not sure if we need to do all that calculation
  # now that it's a tiling texture.
  updateLevel: (level) ->
    level._displayObject.tilePosition.x = -@viewport.pos.x / level.ratio
    level._displayObject.tilePosition.y = -@viewport.pos.y / level.ratio

module.exports = Starfield