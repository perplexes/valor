class Starfield
  constructor: () ->
    @tilesize = 1024 * 2
    @density = 32 * 4
    @levels = [
      @generateTile(2, [184,184,184]),
      @generateTile(3, [96,96,96]),
      # @generateTile(4, [52,52,52]),
      # @generateTile(5, [30,30,30]),
      # @generateTile(6, [19,19,19])
    ]
    
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

    {
      _buffer: buffer
      points: points,
      color: color,
      ratio: ratio
    }

  draw: (viewport, ship, ctx) ->
    @drawLevel(viewport, ship, ctx, level) for level in @levels

  drawLevel: (viewport, ship, ctx, level) ->
    left = Math.floor ((ship.x / level.ratio) - (viewport.width / 2)) / @tilesize 
    top = Math.floor ((ship.y / level.ratio) - (viewport.height / 2)) / @tilesize 
    right = Math.ceil ((ship.x / level.ratio) + (viewport.width / 2)) / @tilesize 
    bottom = Math.ceil ((ship.y / level.ratio) + (viewport.height / 2)) / @tilesize

    x = -ship.x / level.ratio
    y = -ship.y / level.ratio

    pairs = []
    for col in [left..right]
      for row in [top..bottom]
        tileX = col * @tilesize + x
        tileY = row * @tilesize + y
        # ctx.save()
        # ctx.translate(tileX, tileY)
        ctx.drawImage(level._buffer, tileX, tileY, @tilesize, @tilesize)
        # ctx.restore()
        pairs.push([col, row])
    [left, right, top, bottom]