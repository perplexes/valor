class Map
  constructor: (oEvent, stage) ->
    @spriteWidth = @spriteHeight = 16 # in pixels
    @spriteMapWidth = 19 # in tiles
    @spriteMapHeight = 10 # in tiles
    @mapWidth = @mapHeight = 1024 # in tiles
    @mapWidthP = @mapHeightP = 1024 * @spriteWidth # in pixels
    # TODO: Move tree into engine, we need it for ships and bullets
    @tree = new ZTree
    # @tree = new ArrayTree
    # ZTree.test()
    # debugger
    @tileset = @parseLevel(oEvent, @tree)
    # @drawtiles = []
    # @tree.tree.each (tile) =>
    #   if Math.abs(tile.x - (513 * 16)) <= 1000 && Math.abs(tile.y - (397 * 16)) <= 1000
    #     @drawtiles.push tile
    @container = new PIXI.DisplayObjectContainer()
    stage.addChild(@container)
    # spriteMapT = new PIXI.Texture(@baseTexture)
    # spriteMapS = new PIXI.Sprite(spriteMapT)
    # stage.addChild(spriteMapS)
    # for i in [0..@tileset.length-1]
    #   s = new PIXI.Sprite(@tileset[i])
    #   s.position.y = 176
    #   s.position.x = i*16
    #   stage.addChild(s)

    # @stage = stage

  search: (x1, y1, x2, y2) ->
    @tree.search(x1, y1, x2, y2)


  tilesInView: (viewport, ship) ->
    west = ship.x - viewport.width / 2 - @spriteWidth
    north = ship.y - viewport.height / 2 - @spriteHeight
    east = ship.x + viewport.width / 2 + @spriteWidth
    south = ship.y + viewport.height / 2 + @spriteHeight
    # (tile for tile in @drawtiles when west - 16 <= tile.x <= east + 16 && north - 16 <= tile.y <= south + 16)
    @tree.search(west, north, east, south)
    # @drawtiles

  # Mark & sweep :P
  draw: (viewport, ship, tiles) ->
    for tile in tiles
      @drawTile(viewport, ship, tile)

    for tile in @container.children
      if tile._contained && !tile._drawn
        @container.removeChild(tile._sprite)
        tile._contained = false
      tile._drawn = false

  drawTile: (viewport, ship, tile) ->
    return unless tile._sprite
    tile._drawn = true
    unless tile._contained
      @container.addChild(tile._sprite)
      tile._contained = true 

    origin =
      x: ship.x - viewport.width / 2
      y: ship.y - viewport.height / 2

    # Viewport Map x in Pixels
    vpmxp = tile.x - origin.x - 8
    vpmyp = tile.y - origin.y - 8

    tile._sprite.position.x = vpmxp
    tile._sprite.position.y = vpmyp

    info = {vpmxp: vpmxp, vpmyp: vpmyp, tile: tile.index, x: tile.x, y: tile.y}
    info

  parseLevel: (oEvent, tree) ->
    arrayBuffer = oEvent.target.response # Note: not oReq.responseText
    return [] unless arrayBuffer

    # TODO: Use jParser here
    bmpLength = restruct.int32lu("length")
    mapStruct = restruct.int32lu("struct")

    a = new Uint8Array(arrayBuffer)
    
    # if(a[0] == 66 && a[1] == 77){
    bmp_size = bmpLength.unpack(a.subarray(2, 6)).length
    bmp_data = a.subarray(0, bmp_size)
    bmp = new BMPImage(bmp_data.buffer)
    canvas = document.createElement("canvas")
    canvas.name = "tileset"
    bmp.drawToCanvas canvas

    @baseTexture = new PIXI.BaseTexture(canvas)
    textures = []
    for y in [0..@spriteMapHeight-1]
      for x in [0..@spriteMapWidth-1]
        textures.push(new PIXI.Texture(@baseTexture, {x: x * 16, y: y * 16, width: 16, height: 16}))

    # canvas.style.position = "absolute"
    # canvas.style.zIndex = 100
    # canvas.style.top = 0
    # document.body.appendChild canvas
    i = bmp_size

    while i < a.length
      bytes = a.subarray(i, i + 4)
      struct = mapStruct.unpack(bytes).struct
      tx = struct & 0x03FF
      ty = (struct >>> 12) & 0x03FF
      x = tx * 16 + 8
      y = ty * 16 + 8
      index = (struct >>> 24) - 1
      texture = textures[index]
      tree.insert
        tx: tx
        ty: ty
        x: x
        y: y
        min:
          x: x - 8
          y: y - 8
        max:
          x: x + 8
          y: y + 8
        w: 16
        h: 16
        index: index - 1
        _sprite: if texture then new PIXI.Sprite(texture) else null
        meta: [i, length, bytes, struct, struct.toString(2)]
        _contained: false
        _drawn: false
      i += 4

    textures