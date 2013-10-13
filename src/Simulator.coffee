class Simulator
  constructor: (scene) ->
    @scene = scene
    @layers = scene.layers
    @objects = new DLinkedList()

  addObject: (object) ->
    object._simulatorNode = @objects.insert(object)

  removeObject: (object) ->
    @objects.remove(object._simulatorNode)

  simulate: (delta) ->
    @objects.each (object) =>
      for layer in @layers
        continue unless layer.tree
        layer.tree.searchExpand(object._extent, 16, 16, (nearObject) ->
          if Physics.collision(object, nearObject)
            object.collide(nearObject)
        , @)

      object.simulate(delta)