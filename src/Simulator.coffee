class Simulator
  constructor: (scene) ->
    @scene = scene
    @layers = scene.layers
    @objects = new DLinkedList()
    Simulator.simulator = @

  addObject: (object) ->
    object._simulatorNode = @objects.insert(object)

  removeObject: (object) ->
    @objects.remove(object._simulatorNode)

  # Ship -> Tile
  # Bullet -> Tile, Ship
  simulate: (delta) ->
    @objects.each (object) =>
      object.simulate(delta)

      for layer in @layers
        continue unless layer.tree
        layer.tree.searchExpand(object._extent, 16, 16, (nearObject) ->
          return false if object == nearObject
          if Physics.collision(object._extent, nearObject._extent)
            object.collide(nearObject)
        , @)
