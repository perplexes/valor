class Simulator
  constructor: ->
    @staticTree = new ZTree
    @dynamicTree = new ZTree
    @collisions = {}
    # TODO: Track down who uses this and have them go through game instead maybe
    Simulator.simulator = @

  insert: (entity) ->
    @dynamicTree.insert(entity)

  remove: (entity) ->
    @dynamicTree.remove(entity)

  insertStatic: (entity) ->
    @staticTree.insert(entity)

  # TODO: does it make more sense to partition this into
  # quadrants or something, and not search per-object, but just
  # do likely events?
  # Perf test - see if we're using the search too much.
  step: (game, timestamp, delta_s) ->
    @collisions = {}
    @dynamicTree.each (entity) =>
      entity.simulate(delta_s)

      for tree in [@staticTree, @dynamicTree]
        tree.searchExpand(entity._extent, 16, 16, (nearEntity) ->
          return false if entity == nearEntity
          return false if @collisions[entity.hash]
          return false if @collisions[nearEntity.hash]

          if Physics.collision(entity._extent, nearEntity._extent)
            entity.collide(nearEntity)
            nearEntity.collide(entity)

            @collisions[entity.hash] = entity
            @collisions[nearEntity.hash] = nearEntity
        , @)
