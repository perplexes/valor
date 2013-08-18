Physics =
  collision: (a, b) ->
    # Exit with no intersection if found separated along an axis
    return false if a.max.x < b.min.x || a.min.x > b.max.x
    return false if a.max.y < b.min.y || a.min.y > b.max.y
   
    # No separating axis found, therefore there is at least one overlapping axis
    true

  # Combines many surfaces into one surface
  # Only combine ones that share a plane
  # TODO: How?? (Otherwise it's not aabb anymore)
  combine: (as) ->
    # surfaces =
    #   x: {}
    #   y: {}

    # xs = as.group_by(&:x)
    # ys = as.group_by(&:y)

    # xs.map(&:combine)
    # ys.map(&:combine)????


    surface =
      min:
        x: as[0].min.x
        y: as[0].min.y
      max:
        x: as[0].max.x
        y: as[0].max.y

    for a in as
      if a.min.x < surface.min.x
        surface.min.x = a.min.x
      if a.min.y < surface.min.y
        surface.min.y = a.min.y
      if a.max.x > surface.max.x
        surface.max.x = a.max.x
      if a.max.y > surface.max.y
        surface.max.y = a.max.y

    surface.x = surface.min.x + ((surface.max.x - surface.min.x) / 2)
    surface.y = surface.min.y + ((surface.max.y - surface.min.y) / 2)
    surface

  # Returns null on no overlap
  # Returns manifold{}
  #   a (AABB)
  #   b (AABB)
  #   penetration (scalar)
  #   normalX (scalar)
  #   normalY (scalar)
  overlap: (a, b) ->
    normalX = b.x - a.x
    normalY = b.y - a.y
    ax_extent = (a.max.x - a.min.x) / 2
    bx_extent = (b.max.x - b.min.x) / 2

    x_overlap = ax_extent + bx_extent - Math.abs(normalX)

    return null unless x_overlap > 0

    ay_extent = (a.max.y - a.min.y) / 2
    by_extent = (b.max.y - b.min.y) / 2

    y_overlap = ay_extent + by_extent - Math.abs(normalY)

    return null unless y_overlap > 0

    manifold = {
      onX: normalX
      onY: normalY
    }

    # This is essentially:
    # Which edge do we think they hit first?
    # If our physics framerate is high enough,
    # it's the one with less overlap.
    # But we can also see what their velocities are...
    # So in some cases we would want to choose the y overlap
    # if their y vel is higher than their x vel. But when?
    if x_overlap < y_overlap# && Math.abs(a.dx) > Math.abs(a.dy)
      manifold.normalY = 0
      manifold.penetration = x_overlap
      if normalX < 0
        manifold.normalX = -1
      else
        manifold.normalX = 1
    else
      manifold.normalX = 0
      manifold.penetration = y_overlap
      if normalY < 0
        manifold.normalY = -1
      else
        manifold.normalY = 1

    manifold

  # (this.x * v.x + this.y * v.y);
  # Assume for now that a is a ship and b is a tile
  # Return: {
  #  a: [x, y, dx, dy]
  #  b: [x, y, dx, dy]
  # }
  resolve: (a, b, m) ->
    b.dx = 0
    b.dy = 0
    a.invmass = 1
    b.invmass = 0

    rvX = b.dx - a.dx
    rvY = b.dy - a.dy

    vn = rvX * m.normalX + rvY * m.normalY

    # Separating velocity
    return null if vn > 0

    # TODO: Programmable bounciness
    e = 0.5 * Math.abs(vn / a.maxSpeed)

    j = -(1 + e) * vn
    j /= a.invmass + b.invmass

    impulseX = m.normalX * j
    impulseY = m.normalY * j

    ax = bbx = ay = bby = 0

    adx = -a.invmass * impulseX
    ady = -a.invmass * impulseY
    bdx = b.invmass * impulseX
    bdy = b.invmass * impulseY

    # LERP for float drift
    # TODO: Switch to exact integers
    percent = Math.abs(vn / a.maxSpeed)# * 6 (this should be something to counteract dx * delta / 1000)
    slop = 0.01
    c = Math.max(m.penetration - slop, 0)# * percent
    ax = -a.invmass * c * m.normalX
    ay = -a.invmass * c * m.normalY
    bbx = b.invmass * c * m.normalX
    bby = b.invmass * c * m.normalY

    {
      a: [ax, ay, adx, ady],
      b: [bbx, bby, bdx, bdy]
    }