class ArrayTree
  constructor: () ->
    @array = []

  insert: (data) ->
    @array.push(data)

  search: (x1, y1, x2, y2) ->
    results = []
    for tile in @array
      if x1 <= tile.pos.x <= x2
        if y1 <= tile.pos.y <= y2
          results.push tile
    results

  searchExpand: (extent, x, y) ->
    @search(extent.west - x, extent.north - y, extent.east + x, extent.south + y)

  searchExtent: (extent) ->
    @search(extent.west, extent.north, extent.east, extent.south)
