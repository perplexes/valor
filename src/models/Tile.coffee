class Tile extends Entity
  tx: 0
  ty: 0
  index: 0
  meta: []
  _contained: false
  _drawn: false
  mapNode: null
  invmass: 0
  w: 16
  h: 16
  offset: new Vector2d(@::w/2, @::h/2)

  mapStruct = restruct.int32lu("struct")
  constructor: (tx, ty, index, texture, meta, map) ->
    pos = new Vector2d(tx, ty).scaleXY(@w, @h).add(@offset)
    super(null, pos, null, @w, @h)

    @tx = tx
    @ty = ty
    @index = index
    @texture = texture
    @meta = meta
    @map = map

  @fromFile: (array, offset, spriteSheet, map) ->
    tiles = []
    i = offset
    while i < array.length
      bytes = array.subarray(i, i + 4)
      struct = mapStruct.unpack(bytes).struct
      tx = struct & 0x03FF
      ty = (struct >>> 12) & 0x03FF
      # Tiles are 1-indexed
      index = (struct >>> 24) - 1
      meta = [i, bytes, struct, struct.toString(2)]
      
      tile = new Tile(tx, ty, index, meta, map)
      tiles.push(tile)
      i += 4
    tiles
