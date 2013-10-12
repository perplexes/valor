class Map
  spriteWidth: 16
  spriteHeight: 16 # in pixels
  mapWidth: 1024 # in tiles
  mapHeight: 1024
  mapWidthP: 1024 * @spriteWidth # in pixels
  mapHeightP: 1024 * @spriteHeight # in pixels
  container: new PIXI.DisplayObjectContainer()

  constructor: (tree, stage, viewport) ->
    @tree = tree
    @extent = viewport._extent
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

  updateTile: (tile) ->
    tile.update()

  # Mark & sweep :P
  # TODO: removeChild seems to do a lot of work - profile?
  update: (extent) ->
    @tree.searchExpand(extent, @spriteWidth, @spriteHeight, @updateTile, @)

    for tile in @container.children
      if tile._contained && !tile._drawn
        @container.removeChild(tile._sprite)
        tile._contained = false
      tile._drawn = false

  parseLevel: (oEvent) ->
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

    Tile.fromFile(a, bmp_size, canvas, @)
