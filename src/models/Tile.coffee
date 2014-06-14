Entity = require("./Entity")
Vector2d = require("./Vector2d")
restruct = require("restruct")

# 191: Invisible on screen, Visible on radar, Ships can go through them, Items bounce off it, Thors go through it. (if you "launch" an item while in it, the item will float suspended in space)
# 192-215: Invisible on screen, Visible on radar, Solid block (like any other tile)
# 216: a small asteroid, eveyone already knows about this...
# 217: a medium asteroid, everyone alreay knows about this...
# 218: another small asteroid, just the same as the other one, accept the gfx's are alittle diffrent
# 219: a spacestation, everyone knows about this...
# 220: a wormhole, everyone knows about this...
# 221-240: Invisible on screen, Visible on radar, Solid block (like any other tile)
# 241: Invisible on screen, Visible on radar, Ship can go through it but Items dissapear when they touch it.
# 242: Invisible on screen, Invisible on radar, Warps your ship on contact, items bounce off it, Thors dissapear on contact (!)
# 243-251: Invisible on screen, Invisible on radar, Solid block (like any other tile)
# 252: Visible on screen (Animated NME door), Invisible on radar, Items go through it, your ship gets warped after a random amount of time (0-2 seconds) while floating on it.
# 253: Visible on screen (Animated Team door), Invisible on radar, Items go through it, so does your ship.
# 254: Invisible on screen, Invisible on radar, Items go through it, So does your ship. idk what its used for, but it seems you cant door while on/near it.
# 255: Visible On screen (Animated Green Prize), Invisible on radar, Items go through it, So does your Ship. This is a green, but it doesent show up on radar, and no matter how many times you fly over it, you will never pick it up, ever.
class Tile extends Entity
  Entity.extended(@)

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
  # TODO: Resize special tiles to be the size of their texture
  # But what is their origin? (ul)
  constructor: (tx, ty, index, texture, meta, map) ->
    pos = new Vector2d(tx, ty).scaleXY(@w, @h).add(@offset)
    w = @w
    h = @h
    # Medium asteroid
    if index == 217
      w = h = 32
    # Station
    else if index == 219
      w = h = 96
    # Wormhole
    else if index == 220
      w = h = 80

    super(null, pos, null, w, h)

    @tx = tx
    @ty = ty
    @index = index
    @texture = texture
    @meta = meta
    @map = map

  @fromFile: (array, offset, map) ->
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

module.exports = Tile