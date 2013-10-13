class Layer
  constructor: (scene) ->
    @scene = scene
    @tree = new ZTree()
    @container = new PIXI.DisplayObjectContainer()
    # "from space" for scene removal
    @red = new DLinkedList()
    # "to space" for keeping around
    @black = new DLinkedList()
    
    @scene.addLayer(@)

  insert: (object) ->
    @tree.insert(object)

  remove: (object) ->
    @tree.remove(object)

  addChild: (object) ->
    if object._displayObject
      @container.addChild(object._displayObject)

    object._sceneNode = @black.insert(object)

  removeChild: (object) ->
    @removed += 1
    if object._displayObject
      @container.removeChild(object._displayObject)

    object._sceneNode.remove()
    object._sceneNode = null

  # TODO: Assumes largest object is 32x32
  objects: 0
  update: ->
    @objects = 0
    @tree.searchExpand(@scene.viewport._extent, 16, 16, @updateObject, @)

  # TODO: standardize property names (like Go??)
  updateObject: (object) ->
    @objects += 1
    # Copy to black space
    if object._sceneNode
      @black.insertNode(object._sceneNode.remove())
    # Haven't seen it before, add to stage and black space
    else
      @addChild(object)

    object.update()

  removed: 0
  sweep: ->
    @removed = 0
    @red.each(@removeChild, @)
    # Swap spaces
    oldRed = @red
    @red = @black
    @black = oldRed