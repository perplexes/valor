class Tile
  tx: 0
  ty: 0
  x: 0
  y: 0
  min:
    x: 0
    y: 0
  max:
    x: 0
    y: 0
  w: 16
  h: 16
  index: 0
  _sprite: null # PIXI.Sprite
  meta: []
  _contained: false
  _drawn: false

  mapStruct = restruct.int32lu("struct")
  constructor: (tx, ty, index, texture, meta) ->
    @tx = tx
    @ty = ty
    @index = index
    @texture = texture
    @meta = meta

    # TODO: Get coordinates straight.
    # Here x/y are center, but we draw them UL
    # Maybe cause of physics bugs?
    @x = tx * 16 + 8
    @y = ty * 16 + 8
    @min =
      x: x - 8
      y: y - 8
    @max =
      x: x + 8
      y: y + 8
    @_sprite = new PIXI.Sprite(texture) if texture

  @fromFile: (array, offset, spriteSheet, tree) ->
    tiles = []
    base = new PIXI.BaseTexture(spriteSheet)

    textures = []
    for y in [0..@spriteMapHeight-1]
      for x in [0..@spriteMapWidth-1]
        textures.push(new PIXI.Texture(base, {
          x: x * 16,
          y: y * 16,
          width: 16,
          height: 16
        }))

    i = offset
    while i < array.length
      bytes = a.subarray(i, i + 4)
      struct = mapStruct.unpack(bytes).struct
      tx = struct & 0x03FF
      ty = (struct >>> 12) & 0x03FF
      # Tiles are 1-indexed
      index = (struct >>> 24) - 1
      texture = textures[index]
      meta = [i, bytes, struct, struct.toString(2)]
      tile = new Tile(tx, ty, index, texture, meta)
      tiles.push tile
      # TODO: Tell, don't ask here? Callback?
      tree.insert tile
      i += 4