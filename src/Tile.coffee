class Tile extends Entity
  @spriteMapWidth = 19 # in tiles
  @spriteMapHeight = 10 # in tiles
  tx: 0
  ty: 0
  index: 0
  _sprite: null # PIXI.Sprite
  meta: []
  _contained: false
  _drawn: false

  mapStruct = restruct.int32lu("struct")
  constructor: (tx, ty, index, texture, meta, map) ->
    super(new Vector2d(tx * 16 + 8, ty * 16 + 8), null, 16, 16)

    @tx = tx
    @ty = ty
    @index = index
    @texture = texture
    @meta = meta
    @map = map

    if texture
      @_sprite = new PIXI.Sprite(texture) 
      @_sprite.anchor.x = 0.5
      @_sprite.anchor.y = 0.5

  update: ->
    return unless @_sprite
    @_drawn = true
    unless @_contained
      @map.container.addChild(@_sprite)
      @_contained = true 

    @_sprite.position.x = @pos.x - @map.extent.west
    @_sprite.position.y = @pos.y - @map.extent.north

  @fromFile: (array, offset, spriteSheet, map) ->
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
      bytes = array.subarray(i, i + 4)
      struct = mapStruct.unpack(bytes).struct
      tx = struct & 0x03FF
      ty = (struct >>> 12) & 0x03FF
      # Tiles are 1-indexed
      index = (struct >>> 24) - 1
      texture = textures[index]
      meta = [i, bytes, struct, struct.toString(2)]
      
      tile = new Tile(tx, ty, index, texture, meta, map)
      tiles.push tile
      # TODO: Tell, don't ask here? Callback?
      map.tree.insert tile
      i += 4
