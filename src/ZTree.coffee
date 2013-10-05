class ZTree
  B = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF]
  S = [1, 2, 4, 8]
  constructor: () ->
    @tree = new RBTree((a, b) ->
      a.zcode - b.zcode
    )

  # Node must have x and y integers
  insert: (node) ->
    node.zcode = @zEncode(node.x, node.y)
    @tree.insert(node)

  # Interleave lower 16 bits of x and y, so the bits of x
  # are in the even positions and bits from y in the odd
  # z gets the resulting 32-bit Morton Number.
  # x and y must initially be less than 65536.
  zEncode: (x, y) ->
    x = (x | (x << S[3])) & B[3]
    x = (x | (x << S[2])) & B[2]
    x = (x | (x << S[1])) & B[1]
    x = (x | (x << S[0])) & B[0]

    y = (y | (y << S[3])) & B[3]
    y = (y | (y << S[2])) & B[2]
    y = (y | (y << S[1])) & B[1]
    y = (y | (y << S[0])) & B[0]

    return x | (y << 1)

  search: (x1, y1, x2, y2) ->
    [z1, z2] = [@zEncode(x1, y1), @zEncode(x2, y2)]
    recurse = (node, minz, maxz, nodes=[]) =>
      return nodes unless node
      z = node.data.zcode
      return recurse(node.right, minz, maxz, nodes) if z < minz
      return recurse(node.left, minz, maxz, nodes) if z > maxz
      if x1 <= node.x <= x2 && y1 <= node.y <= y2
        recurse(node.left, minz, z).
        concat([node]).
        concat(recurse(node.right, z, maxz))
      else
        recurse(node.left, minz, @cleverLitmax(z1, z2, z)).
        concat(recurse(node.right, @cleverBigmin(z1, z2, z), maxz))

    recurse(@tree._root, z1, z2)

  stupidLitmax: (x1, y1, x2, y2, minz, maxz, z) ->
    candidate = minz
    console.log(x2+1 - x1, y2+1 - y1)
    debugger
    for x in [x1..x2+1]
      for y in [y1..y2+1]
        console.log("stupidLitmax", x, y)
        zc = @zEncode(x, y)
        if zc > z and zc < candidate
          candidate = z
    candidate

  stupidBigmin: (x1, y1, x2, y2, minz, maxz, z) ->
    candidate = maxz
    for x in [x1..x2+1]
      for y in [y1..y2+1]
        console.log("stupidBigmin", x, y)
        zc = @zEncode(x, y)
        if zc > z and zc < candidate
          candidate = z
    candidate

  _000_ = 0
  _001_ = 1
  _010_ = 1 << 1
  _011_ = (1 << 1)|1
  _100_ = 1 << 2
  _101_ = (1 << 2)|1

  MASK = 0xaaaaa # hex(int('10'*10, 2))

  FULL = 0xffffffff

  setbits: (p, v) ->
    mask = (MASK >> (19-p)) & (~(FULL << p) & FULL)
    (v | mask) & ~(1 << p) & FULL

  unsetbits: (p, v) ->
    mask = ~(MASK >> (19-p)) & FULL
    (v & mask) | (1 << p)

  cleverLitmax: (minz, maxz, zcode) ->
    litmax = minz
    for p in [19..0]
      mask = 1 << p
      v = (zcode & mask) && _100_ || _000_
      if minz & mask then v |= _010_
      if maxz & mask then v |= _001_

      if v == _001_
        maxz = @setbits(p, maxz)
      else if v == _011_
        return litmax
      else if v == _100_
        return maxz
      else if v == _101_
        litmax = @setbits(p, maxz)
        minz = @unsetbits(p, minz)

    litmax

  cleverBigmin: (min, maxz, zcode) ->
    bigmin = maxz
    for p in [19..0]
      mask = 1 << p
      v = (zcode & mask) && _100_ || _000_
      if minz & mask then v |= _010_
      if maxz & mask then v |= _001_

      if v == _001_
        bigmin = @unsetbits(p, minz)
        maxz = @setbits(p, maxz)
      else if v == _011_
        return minz
      else if v == _100_
        return bigmin
      else if v == _101_
        minz = @unsetbits(p, minz)

    bigmin

  @test: ->
    tree = new ZTree
    for x in [0..9]
      for y in [0..17]
        tree.insert
          x: x,
          y: y

    tree.tree.each (d) ->
      console.log(d)

    console.log 'search', tree.search(3, 5, 5, 10)
    console.log 'litmax', tree.cleverLitmax(tree.zEncode(3, 5), tree.zEncode(5, 10), 58)
    console.log 'bigmin', tree.cleverBigmin(tree.zEncode(3, 5), tree.zEncode(5, 10), 58)