class Map
  spriteWidth: 16
  spriteHeight: 16 # in pixels
  mapWidth: 1024 # in tiles
  mapHeight: 1024
  mapWidthP: 1024 * @spriteWidth # in pixels
  mapHeightP: 1024 * @spriteHeight # in pixels

  constructor: (layer) ->
    @layer = layer

  load: (callback) ->
    oReq = new XMLHttpRequest()
    # TODO: Parameterize
    oReq.open "GET", "../arenas/trench9.lvl", true
    oReq.responseType = "arraybuffer"
    oReq.onload = (oEvent) =>
      @parseLevel(oEvent)
      callback()

    oReq.send null

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
