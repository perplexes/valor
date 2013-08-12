class Map
  constructor: (oEvent) ->
    [@tileset, @tiles] = @parseLevel(oEvent)
    # @tree = zOrderTree(@tiles)
    @spriteWidth = @spriteHeight = 16 # in pixels
    @spriteMapWidth = 19 # in tiles
    @spriteMapHeight = 10 # in tiles
    @mapWidth = @mapHeight = 1024 # in tiles
    @mapWidthP = @mapHeightP = 1024 * @spriteWidth # in pixels
    # @drawtiles = (tile for tile in @tiles when Math.abs(tile.x - 524) <= 1000 && Math.abs(tile.y - 628) <= 1000)


  draw: (viewport, ship, ctx) ->
    # tiles = @tree.search(
    west = ship.x - viewport.width / 2
    north = ship.y - viewport.height / 2
    east = ship.x + viewport.width / 2
    south = ship.y + viewport.height / 2
    res = (@drawTile(viewport, ship, ctx, tile) for tile in @tiles when west - 16 <= tile.x * 16 <= east && north - 16 <= tile.y * 16 <= south)
    res

  drawTile: (viewport, ship, ctx, tile) ->
    origin =
      x: ship.x - viewport.width / 2
      y: ship.y - viewport.height / 2

    row = Math.floor((tile.index - 1) / @spriteMapWidth)
    col = (tile.index - 1) % @spriteMapWidth
    smxp = col * @spriteWidth
    smyp = row * @spriteHeight
    mxp = tile.x * @spriteWidth
    myp = tile.y * @spriteHeight
    vpmxp = mxp - origin.x
    vpmyp = myp - origin.y

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

  parseLevel: (oEvent) ->
    arrayBuffer = oEvent.target.response # Note: not oReq.responseText
    return [] unless arrayBuffer

    # TODO: Use jParser here
    bmpLength = restruct.int32lu("length")
    mapStruct = restruct.int32lu("struct")
    tiles = []

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
      x = struct & 0x03FF
      y = (struct >>> 12) & 0x03FF
      index = struct >>> 24
      tiles.push
        x: x
        y: y
        index: index
        meta: [i, length, bytes, struct, struct.toString(2)]
      i += 4

    [canvas, tiles]