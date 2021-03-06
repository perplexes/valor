# UBTree = require("./UBTree")
RbushTree = require("./RbushTree")
DLinkedList = require("./DLinkedList")
Physics = require("./Physics")

class Simulator
  constructor: ->
    @staticTree = new RbushTree
    @dynamicTree = new RbushTree
    @dynamicEntities = new DLinkedList
    @collisions = {}
    @collObjs = []
    # TODO: Track down who uses this and have them go through game instead maybe
    Simulator.simulator = @

  insert: (entity) ->
    @dynamicTree.insert(entity)
    @dynamicEntities.insert(entity, entity.hash)

  remove: (entity) ->
    @dynamicTree.remove(entity)
    @dynamicEntities.remove(entity.hash)

  # TODO: Deformable map
  insertStatic: (staticEntities) ->
    @staticTree.load(staticEntities)

  # TODO: does it make more sense to partition this into
  # quadrants or something, and not search per-object, but just
  # do likely events?
  # Perf test - see if we're using the search too much.
  # TODO: allocations
  step: (game, timestamp, delta_s) ->
    @collisions = {}
    @collObjs = []
    @simulated = []
    @dynamicEntities.each (entity) =>
      entity.simulate(delta_s)
      @simulated.push entity

      for tree in [@staticTree, @dynamicTree]
        tree.searchExpand(entity._extent, 16, 16, (nearEntity) ->
          return false if entity == nearEntity
          pair = @pair(entity.hash, nearEntity.hash)
          return false if @collisions[pair]

          if Physics.collision(entity._extent, nearEntity._extent)
            entity.collide(nearEntity)
            nearEntity.collide(entity)

            @collisions[pair] = true
            @collObjs.push(nearEntity)
            @collObjs.push(entity)
        , @)

  # http://stackoverflow.com/a/13871379
  pair: (a, b) ->
    if a >= b
      a * a + a + b
    else
      a + b * b

module.exports = Simulator
