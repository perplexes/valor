restruct = require("restruct")
Tile = require("./Tile.js")
class Map
  spriteWidth: 16
  spriteHeight: 16 # in pixels
  mapWidth: 1024 # in tiles
  mapHeight: 1024
  mapWidthP: 1024 * @spriteWidth # in pixels
  mapHeightP: 1024 * @spriteHeight # in pixels

  @load: (callback) ->
    if window?
      oReq = new XMLHttpRequest()
      # TODO: Parameterize, drag n drop
      oReq.open "GET", "assets/arenas/trench9.lvl", true
      oReq.responseType = "arraybuffer"
      oReq.onload = (oEvent) =>
        console.log oEvent
        [bmpData, tiles] = @parseLevel(oEvent.target.response)
        callback(bmpData, tiles)

      oReq.send null
    else
      fs = require('fs')
      fs.readFile 'assets/arenas/trench9.lvl', (err, data) =>
        [bmpData, tiles] = @parseLevel(data)
        callback(bmpData, tiles)

  @parseLevel: (arrayBuffer) ->
    return [] unless arrayBuffer

    # TODO: Use jParser here
    bmpLength = restruct.int32lu("length")

    a = new Uint8Array(arrayBuffer)
    
    # if(a[0] == 66 && a[1] == 77){
    bmp_size = bmpLength.unpack(a.subarray(2, 6)).length
    bmp_data = a.subarray(0, bmp_size)

    [bmp_data, Tile.fromFile(a, bmp_size, @)]

module.exports = Map