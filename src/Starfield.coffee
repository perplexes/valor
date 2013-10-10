# TODO: Use RenderTexture?
class Starfield
  constructor: (viewport, stage) ->
    @tilesize = 1024 * 2
    @density = 32 * 4
    @levels = [
      @generateTile(viewport, 2, [184,184,184]),
      @generateTile(viewport, 3, [96,96,96]),
      @generateTile(viewport, 4, [52,52,52]),
      @generateTile(viewport, 5, [30,30,30]),
      @generateTile(viewport, 6, [19,19,19])
    ]

    for level in @levels
      stage.addChild(level._sprite)
    
  generateTile: (viewport, ratio, color) ->
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
    sprite = new PIXI.TilingSprite(texture, viewport.w, viewport.h)

    {
      _texture: texture,
      _sprite: sprite,
      points: points,
      color: color,
      ratio: ratio
    }

  update: (viewport) ->
    @updateLevel(viewport, level) for level in @levels

  # How to take ship out?
  updateLevel: (viewport, level) ->
    x = viewport.pos.x / level.ratio
    y = viewport.pos.y / level.ratio

    left = Math.floor (x - viewport.hw) / @tilesize 
    top = Math.floor (y - viewport.hh) / @tilesize 
    right = Math.ceil (x + viewport.hw) / @tilesize 
    bottom = Math.ceil (y + viewport.hh) / @tilesize

    # pairs = []
    for col in [left..right]
      for row in [top..bottom]
        level._sprite.tilePosition.x = col * @tilesize - x
        level._sprite.tilePosition.y = row * @tilesize - y
        # pairs.push([col, row])
    # [left, right, top, bottom]