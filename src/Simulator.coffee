class Simulator
  constructor: (scene) ->
    @scene = scene
    @layers = scene.layers
    @objects = new DLinkedList()
    @collisions = []
    Simulator.simulator = @

  addObject: (object) ->
    object._simulatorNode = @objects.insert(object)

  removeObject: (object) ->
    @objects.remove(object._simulatorNode)

  # Ship -> Tile
  # Bullet -> Tile, Ship
  step: (delta) ->
    @collisions = []
    @objects.each (object) =>
      object.simulate(delta)

      for layer in @layers
        continue unless layer.tree
        layer.tree.searchExpand(object._extent, 16, 16, (nearObject) ->
          return false if object == nearObject
          if Physics.collision(object._extent, nearObject._extent)
            @collisions.push nearObject
            object.collide(nearObject)
        , @)
