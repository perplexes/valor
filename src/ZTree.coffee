class ZTree
  B = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF]
  S = [1, 2, 4, 8]
  constructor: () ->
    @tree = new RBTree((a, b) ->
      a.zindex < b.zindex
    )

  # Node must have x and y integers
  insert: (node) ->
    node.zindex = @z_encode(node.x, node.y)
    @tree.insert(node)

  # Interleave lower 16 bits of x and y, so the bits of x
  # are in the even positions and bits from y in the odd
  # z gets the resulting 32-bit Morton Number.
  # x and y must initially be less than 65536.
  z_encode: (x, y) ->
    x = (x | (x << S[3])) & B[3]
    x = (x | (x << S[2])) & B[2]
    x = (x | (x << S[1])) & B[1]
    x = (x | (x << S[0])) & B[0]

    y = (y | (y << S[3])) & B[3]
    y = (y | (y << S[2])) & B[2]
    y = (y | (y << S[1])) & B[1]
    y = (y | (y << S[0])) & B[0]

    return x | (y << 1)

  