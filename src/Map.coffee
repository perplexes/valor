class Map
  constructor: (oEvent) ->
    @tree = new ZTree
    ZTree.test()
    debugger
    @tileset = @parseLevel(oEvent, @tree)
    # @tree = zOrderTree(@tiles)
    @spriteWidth = @spriteHeight = 16 # in pixels
    @spriteMapWidth = 19 # in tiles
    @spriteMapHeight = 10 # in tiles
    @mapWidth = @mapHeight = 1024 # in tiles
    @mapWidthP = @mapHeightP = 1024 * @spriteWidth # in pixels
    # @drawtiles = (tile for tile in @tiles when Math.abs(tile.x - 524) <= 1000 && Math.abs(tile.y - 628) <= 1000)

  tilesInView: (viewport, ship) ->
    west = ship.x - viewport.width / 2
    north = ship.y - viewport.height / 2
    east = ship.x + viewport.width / 2
    south = ship.y + viewport.height / 2
    # (tile for tile in @tiles when west - 16 <= tile.x <= east + 16 && north - 16 <= tile.y <= south + 16)
    @tree.search(west, north, east, south)

  draw: (viewport, ship, tiles, ctx) ->
    @drawTile(viewport, ship, ctx, tile) for tile in tiles

  drawTile: (viewport, ship, ctx, tile) ->
    origin =
      x: ship.x - viewport.width / 2
      y: ship.y - viewport.height / 2

    row = tile.index / @spriteMapWidth | 0
    col = tile.index % @spriteMapWidth

    # Sprite Map x in Pixels
    smxp = col * @spriteWidth
    smyp = row * @spriteHeight
    # Viewport Map x in Pixels
    vpmxp = tile.x - origin.x - 8
    vpmyp = tile.y - origin.y - 8

    # debugger if tile.index < 190

    args = [
      @tileset,
      smxp, smyp,
      @spriteWidth, @spriteHeight,
      vpmxp, vpmyp,
      @spriteWidth, @spriteHeight
    ]
    info = {smxp: smxp, smyp: smyp, vpmxp: vpmxp, vpmyp: vpmyp, tile: tile.index, x: tile.x, y: tile.y}
    # console.log(info)
    # console.log(info) if 0 <= vpmyp <= viewport.width && 0 <= vpmyp <= viewport.height

    ctx.drawImage(args...)
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
      index = struct >>> 24
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
        meta: [i, length, bytes, struct, struct.toString(2)]
      i += 4

    canvas