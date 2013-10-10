class Map
  spriteWidth: 16
  spriteHeight: 16 # in pixels
  mapWidth: 1024 # in tiles
  mapHeight: 1024
  mapWidthP: 1024 * @spriteWidth # in pixels
  mapHeightP: 1024 * @spriteHeight # in pixels
  container: new PIXI.DisplayObjectContainer()

  constructor: (tree, stage) ->
    @tree = tree
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

  tilesInView: (extent) ->
    @tree.searchExpand(extent, @spriteWidth, @spriteHeight)

  # Mark & sweep :P
  # TODO: removeChild seems to do a lot of work - profile?
  update: (extent) ->
    for tile in @tilesInView(extent)
      @drawTile(extent, tile)

    for tile in @container.children
      if tile._contained && !tile._drawn
        @container.removeChild(tile._sprite)
        tile._contained = false
      tile._drawn = false

  drawTile: (extent, tile) ->
    return unless tile._sprite
    tile._drawn = true
    unless tile._contained
      @container.addChild(tile._sprite)
      tile._contained = true 

    tile._sprite.position.x = tile.pos.x - extent.west - 8
    tile._sprite.position.y = tile.pos.y - extent.north - 8

    # info = {vpmxp: vpmxp, vpmyp: vpmyp, tile: tile.index, x: tile.x, y: tile.y}
    # info

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
