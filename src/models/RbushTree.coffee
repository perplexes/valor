Extent = require("./Extent")
Rbush = require("rbush")

class RbushTree
  constructor: () ->
    @tree = Rbush()
    @tree.toBBox = (entity) ->
      return entity._extent
    @tree.compareMinX = (a, b) ->
      return a._extent.ul.x - b._extent.ul.x
    @tree.compareMinY = (a, b) ->
      return a._extent.ul.y - b._extent.ul.y

  # TODO: bulk remove/insert
  insert: (entity) ->
    @tree.insert(entity)

  # TODO: Need old inserted extant??
  remove: (entity) ->
    @tree.remove(entity)

  # Used to figure out what to simulate
  # TODO: Allocates
  each: (callback) ->
    for entity in @all()
      callback.call(entity)

  all: ->
    @tree.all()

  load: (entities) ->
    @tree.load(entities)

  expandExtent = new Extent
  searchExpand: (extent, x, y, callback, scope) ->
    expandExtent.clear().add(extent).expand(x, y)
    @searchExtent(
      expandExtent,
      callback,
      scope
    )

  # TODO: Searching allocates :(
  searchExtent: (extent, callback, scope) ->
    entities = @tree.search(extent)
    for entity in entities
      callback.call(scope, entity)

module.exports = RbushTree
