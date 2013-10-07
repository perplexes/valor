class ArrayTree
  constructor: () ->
    @array = []

  insert: (data) ->
    @array.push(data)

  search: (x1, y1, x2, y2) ->
    results = []
    for tile in @array
      if x1 <= tile.x <= x2
        if y1 <= tile.y <= y2
          results.push tile
    results
