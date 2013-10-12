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
    @layer = new DLinkedList()
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

  tileLength: 0
  tiles: []
  updateTile: (tile) ->
    if tile._sprite
      @tileLength += 1 
      @tiles.push tile
      tile.update()

  layerLength: 0
  sweep: (tile) ->
    @layerLength += 1
    unless tile._drawn
      @container.removeChild(tile._sprite)
      @layer.remove(tile._contained)
      tile._contained = null
      
    tile._drawn = false

  # Mark & sweep :P
  # TODO: removeChild seems to do a lot of work - profile?
  update: (extent) ->
    @tileLength = 0
    @layerLength = 0
    @tiles = []
    @tree.searchExpand(@extent, @spriteWidth, @spriteHeight, @updateTile, @)
    @layer.each(@sweep, @)

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
