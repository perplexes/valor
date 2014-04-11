class ZTree
  B = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF]
  # 01010101010101010101010101010101
  # 00110011001100110011001100110011
  # 00001111000011110000111100001111
  # 00000000111111110000000011111111
  S = [1, 2, 4, 8]
  constructor: () ->
    @tree = new RBTree((a, b) ->
      a.zcode - b.zcode
    )

  # Node must have x and y integers
  insert: (entity) ->
    entity.zcode = @zEncode(entity.pos.x|0, entity.pos.y|0)
    @tree.insert(entity)

  remove: (entity) ->
    @tree.remove(entity)

  # Interleave lower 16 bits of x and y, so the bits of x
  # are in the even positions and bits from y in the odd
  # z gets the resulting 32-bit Morton Number.
  # x and y must initially be less than 65536.
  zEncode: (y, x) ->
    x = (x | (x << S[3])) & B[3]
    x = (x | (x << S[2])) & B[2]
    x = (x | (x << S[1])) & B[1]
    x = (x | (x << S[0])) & B[0]

    y = (y | (y << S[3])) & B[3]
    y = (y | (y << S[2])) & B[2]
    y = (y | (y << S[1])) & B[1]
    y = (y | (y << S[0])) & B[0]

    return x | (y << 1)

  expandExtent = new Extent
  searchExpand: (extent, x, y, callback, scope) ->
    expandExtent.clear().add(extent).expand(x, y)
    @searchExtent(
      expandExtent,
      callback,
      scope
    )

  searchExtent: (extent, callback, scope) ->
    @search(
      extent.ul.x,
      extent.ul.y,
      extent.lr.x,
      extent.lr.y,
      callback,
      scope
    )

  # TODO: Iterative
  searchR: (node, minz, maxz, x1, y1, x2, y2, z1, z2, callback, scope) ->
    return unless node
    z = node.data.zcode
    return @searchR(node.right, minz, maxz, x1, y1, x2, y2, z1, z2, callback, scope) if z < minz
    return @searchR(node.left, minz, maxz, x1, y1, x2, y2, z1, z2, callback, scope) if z > maxz
    # This can be simplified with fail-first
    if x1 <= node.data.pos.x <= x2 && y1 <= node.data.pos.y <= y2
      #console.log(["searchdepth:",depth])
      @searchR(node.left, minz, z, x1, y1, x2, y2, z1, z2, callback, scope)
      callback.call(scope, node.data)
      @searchR(node.right, z, maxz, x1, y1, x2, y2, z1, z2, callback, scope)
    else
      @searchR(node.left, minz, @cleverLitmax(z1, z2, z), x1, y1, x2, y2, z1, z2, callback, scope)
      @searchR(node.right, @cleverBigmin(z1, z2, z), maxz, x1, y1, x2, y2, z1, z2, callback, scope)

  search: (x1, y1, x2, y2, callback, scope) ->
    x1 |= 0
    y1 |= 0
    x2 |= 0
    y2 |= 0

    z1 = @zEncode(x1, y1)
    z2 = @zEncode(x2, y2)

    @searchR(@tree._root, z1, z2, x1, y1, x2, y2, z1, z2, callback, scope)

    # ITERATIVE WORK
    #     [minz, maxz] = [@zEncode(x1, y1), @zEncode(x2, y2)]
    # result = []
    # node = @tree._root

    # return result unless cur
    # z = node.data.zcode
    # if z < minz
    #   node = node.right
    #   continue
    # if z > maxz
    #   node = node.left

    # # This can be simplified with fail-first
    # if x1 <= node.data.x <= x2 && y1 <= node.data.y <= y2
    #   result.push node.data
      
    #   # Go left, then right, but how?
    #   cur = node.left
    #   maxz = z
    #   continue

    #   cur = node.right
    #   minz = z
    #   continue
    # else
    #   recurse(node.left, minz, @cleverLitmax(z1, z2, z), depth+1).
    #   concat(recurse(node.right, @cleverBigmin(z1, z2, z), maxz, depth+1))

    # recurse(@tree._root, z1, z2)

  stupidLitmax: (x1, y1, x2, y2, minz, maxz, z) ->
    candidate = minz
    for x in [x1..x2]
      for y in [y1..y2]
        zc = @zEncode(x, y)
        if zc > z and zc < candidate
          candidate = z
    candidate

  stupidBigmin: (x1, y1, x2, y2, minz, maxz, z) ->
    candidate = maxz
    for x in [x1..x2]
      for y in [y1..y2]
        zc = @zEncode(x, y)
        if zc > z and zc < candidate
          candidate = z
    candidate

  _000_ = 0
  _001_ = 1
  _010_ = 2
  _011_ = 3
  _100_ = 4
  _101_ = 5

  MASK = 0xaaaaaaaa # hex(int('10'*10, 2))

  FULL = 0xffffffff

  BITMAX = 31

  setbits: (p, v) ->
    mask = (MASK >>> (BITMAX-p)) & (~(FULL << p) & FULL)
    (v | mask) & ~(1 << p) & FULL

  unsetbits: (p, v) ->
    mask = ~(MASK >>> (BITMAX-p)) & FULL
    (v & mask) | (1 << p)

  cleverLitmax: (minz, maxz, zcode) ->
    litmax = minz
    for p in [BITMAX..0]
      mask = 1 << p
      v = (zcode & mask) && _100_ || _000_
      if minz & mask then v |= _010_
      if maxz & mask then v |= _001_

      # console.log(["cl",p,v,minz,maxz,litmax])

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

  cleverBigmin: (minz, maxz, zcode) ->
    bigmin = maxz
    for p in [BITMAX..0]
      mask = 1 << p
      v = (zcode & mask) && _100_ || _000_
      if minz & mask then v |= _010_
      if maxz & mask then v |= _001_

      # console.log(["cb",p,v,minz,maxz,bigmin])

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

    [zmin, zmax] = [tree.zEncode(3, 5), tree.zEncode(5, 10)]
    z = 58

    console.log 'search', tree.search(3, 5, 5, 10)
    console.log 'slitmax', tree.stupidLitmax(3, 5, 5, 10, zmin, zmax, z)
    console.log 'sbigmin', tree.stupidBigmin(3, 5, 5, 10, zmin, zmax, z)
    console.log 'clitmax', tree.cleverLitmax(zmin, zmax, z)
    console.log 'cbigmin', tree.cleverBigmin(zmin, zmax, z)
    # console.log(tree.cleverBigmin(zmin, zmax, z))

    # for p in [19..0]
    #   for v in [0..10]
    #       console.log [p, v, tree.unsetbits(p, v)] 