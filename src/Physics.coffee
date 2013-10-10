class Physics
  @collision: (a, b) ->
    # Exit with no intersection if found separated along an axis
    return false if a.max.x < b.min.x || a.min.x > b.max.x
    return false if a.max.y < b.min.y || a.min.y > b.max.y
   
    # No separating axis found, therefore there is at least one overlapping axis
    true

  # Returns null on no overlap
  # Returns manifold{}
  #   a (AABB)
  #   b (AABB)
  #   penetration (scalar)
  #   normalX (scalar)
  #   normalY (scalar)

  normal = new Vector2d(0, 0)
  manifold = 
    normal: @normal
    penetration: 0

  @overlap: (a, b) ->
    manifold.penetration = 0

    normal.clear()
    normal.add(b.pos).sub(a.pos)

    x_overlap = a.hw + b.hw - Math.abs(normal.x)

    return null unless x_overlap > 0

    y_overlap = a.hh + b.hh - Math.abs(normal.y)

    return null unless y_overlap > 0

    # This is essentially:
    # Which edge do we think they hit first?
    # If our physics framerate is high enough,
    # it's the one with less overlap.
    # But we can also see what their velocities are...
    # So in some cases we would want to choose the y overlap
    # if their y vel is higher than their x vel. But when?
    if x_overlap < y_overlap# && Math.abs(a.dx) > Math.abs(a.dy)
      normal.y = 0
      manifold.penetration = x_overlap
      if normal.x < 0
        normal.x = -1
      else
        normal.x = 1
    else
      normal.x = 0
      manifold.penetration = y_overlap
      if normal.y < 0
        normal.y = -1
      else
        normal.y = 1

    manifold

  # (this.x * v.x + this.y * v.y);
  # Return: {
  #  a: [x, y, dx, dy]
  #  b: [x, y, dx, dy]
  # }
  rv = new Vector2d(0,0)
  impulse = new Vector2d(0,0)
  @resolve: (a, b) ->
    return null unless m = overlap(a, b)

    rv.clear()
    rv.add(b.vel).sub(a.vel)

    vn = rv.dot(m.normal)

    # Separating velocity
    return null if vn > 0

    # TODO: Programmable bounciness
    e = 0.727 * Math.abs(vn / a.maxSpeed)

    j = -(1 + e) * vn
    j /= a.invmass + b.invmass

    impulse.clear()
    impulse.add(m.normal).scaleXY(j, j)

    a.vel.sub(a.invmass * impulse.x, a.invmass * impulse.y)
    b.vel.add(b.invmass * impulse.x, b.invmass * impulse.y)

    # LERP for float drift
    # TODO: Switch to exact integers
    percent = Math.abs(vn / a.maxSpeed)# * 6 (this should be something to counteract dx * delta / 1000)
    slop = 0.01
    c = Math.max(m.penetration - slop, 0)# * percent

    a.pos.sub(a.invmass * c * m.normal.x, a.invmass * c * m.normal.y)
    b.pos.add(b.invmass * c * m.normal.x, b.invmass * c * m.normal.y)

      # Combines many surfaces into one surface
  # Only combine ones that share a plane
  # TODO: How?? (Otherwise it's not aabb anymore)
  # combine: (as) ->
  #   surface =
  #     min:
  #       x: as[0].min.x
  #       y: as[0].min.y
  #     max:
  #       x: as[0].max.x
  #       y: as[0].max.y

  #   for a in as
  #     if a.min.x < surface.min.x
  #       surface.min.x = a.min.x
  #     if a.min.y < surface.min.y
  #       surface.min.y = a.min.y
  #     if a.max.x > surface.max.x
  #       surface.max.x = a.max.x
  #     if a.max.y > surface.max.y
  #       surface.max.y = a.max.y

  #   surface.x = surface.min.x + ((surface.max.x - surface.min.x) / 2)
  #   surface.y = surface.min.y + ((surface.max.y - surface.min.y) / 2)
  #   surface