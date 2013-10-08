class Map
  constructor: (viewport, tree, stage) ->
    @spriteWidth = @spriteHeight = 16 # in pixels
    @spriteMapWidth = 19 # in tiles
    @spriteMapHeight = 10 # in tiles
    @mapWidth = @mapHeight = 1024 # in tiles
    @mapWidthP = @mapHeightP = 1024 * @spriteWidth # in pixels

    @tree = tree
    
    @container = new PIXI.DisplayObjectContainer()
    stage.addChild(@container)

  load: (callback) ->
    oReq = new XMLHttpRequest()
    # TODO: Parameterize
    oReq.open "GET", "../arenas/trench9.lvl", true
    oReq.responseType = "arraybuffer"
    oReq.onload = (oEvent) =>
      @parseLevel(oEvent, @tree)
      callback()

    oReq.send null

  tilesInView: (viewport, ship) ->
    west = ship.x - viewport.width / 2 - @spriteWidth
    north = ship.y - viewport.height / 2 - @spriteHeight
    east = ship.x + viewport.width / 2 + @spriteWidth
    south = ship.y + viewport.height / 2 + @spriteHeight
    # (tile for tile in @drawtiles when west - 16 <= tile.x <= east + 16 && north - 16 <= tile.y <= south + 16)
    @tree.search(west, north, east, south)
    # @drawtiles

  # Mark & sweep :P
  # TODO: removeChild seems to do a lot of work - profile?
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

    # TODO precalc/share
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

    a = new Uint8Array(arrayBuffer)
    
    # if(a[0] == 66 && a[1] == 77){
    bmp_size = bmpLength.unpack(a.subarray(2, 6)).length
    bmp_data = a.subarray(0, bmp_size)
    bmp = new BMPImage(bmp_data.buffer)
    canvas = document.createElement("canvas")
    canvas.name = "tileset"
    bmp.drawToCanvas canvas

    Tile.fromFile(a, bmp_size, canvas, tree)
