class Physics
  @collision: (a, b) ->
    # debugger if a.west == null
    # debugger if a.east == null
    # debugger if a.north == null
    # debugger if a.south == null
    # debugger if b.west == null
    # debugger if b.east == null
    # debugger if b.north == null
    # debugger if b.south == null
    # Exit with no intersection if found separated along an axis
    return false if a.east < b.west || a.west > b.east
    return false if a.south < b.north || a.north > b.south
   
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
    normal: normal
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
  friction = 0.8
  @resolve: (a, b) ->
    return null unless m = @overlap(a, b)

    rv.clear()
    rv.add(b.vel).sub(a.vel)

    vn = rv.dot(m.normal)

    # Separating velocity
    return null if vn > 0

    # TODO: Programmable bounciness
    e = a.bounciness
    e *= Math.abs(vn / a.maxSpeed) if a.maxSpeed?

    j = -(1 + e) * vn
    j /= a.invmass + b.invmass

    impulse.clear()
    impulse.add(m.normal).scaleXY(j, j)

    a.vel
      .scaleXY(friction, friction)
      .subXY(a.invmass * impulse.x, a.invmass * impulse.y)

    b.vel
      .scaleXY(friction, friction)
      .addXY(b.invmass * impulse.x, b.invmass * impulse.y)

    # TODO: special case for stopping on a wall?

    # LERP for float drift
    # TODO: Switch to exact integers
    percent = Math.abs(vn / a.maxSpeed)# * 6 (this should be something to counteract dx * delta / 1000)
    slop = 0.01
    c = Math.max(m.penetration - slop, 0)# * percent

    a.pos.subXY(a.invmass * c * m.normal.x, a.invmass * c * m.normal.y)
    b.pos.addXY(b.invmass * c * m.normal.x, b.invmass * c * m.normal.y)

      # Combines many surfaces into one surface
  # Only combine ones that share a plane
  # TODO: How?? (Otherwise it's not aabb anymore)
  # combine: (as) ->
  #   surface =
  #     min:
  #       x: as[0].west
  #       y: as[0].north
  #     max:
  #       x: as[0].east
  #       y: as[0].south

  #   for a in as
  #     if a.west < surface.west
  #       surface.west = a.west
  #     if a.north < surface.north
  #       surface.north = a.north
  #     if a.east > surface.east
  #       surface.east = a.east
  #     if a.south > surface.south
  #       surface.south = a.south

  #   surface.x = surface.west + ((surface.east - surface.west) / 2)
  #   surface.y = surface.north + ((surface.south - surface.north) / 2)
  #   surface