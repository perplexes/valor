class Layer
  @layers = {}
  constructor: (name, scene) ->
    @name = name
    Layer.layers[name] = @
    
    @scene = scene
    @tree = new ZTree()
    @container = new PIXI.DisplayObjectContainer()
    # "from space" for scene removal
    @red = new DLinkedList()
    # "to space" for keeping around
    @black = new DLinkedList()

    @scene.addLayer(@)

  insert: (entity) ->
    entity._hasGametreeNode = @tree.insert(entity)

  remove: (entity) ->
    return unless entity._hasGametreeNode
    @tree.remove(entity)
    entity._hasGametreeNode = false

  addChild: (entity) ->
    if entity._displayObject
      @container.addChild(entity._displayObject)

    entity._containerNode = @black.insert(entity)

  removeChild: (entity) ->
    return unless entity._containerNode
    
    @removed += 1
    if entity._displayObject
      @container.removeChild(entity._displayObject)

    entity._containerNode.remove()
    entity._containerNode = null

  # TODO: Assumes largest entity is 32x32
  entities: 0
  update: (gametime) ->
    @entities = 0
    @gametime = gametime
    @tree.searchExpand(@scene.viewport._extent, 16, 16, @updateObject, @)

  # TODO: standardize property names (like Go??)
  updateObject: (entity) ->
    @entities += 1
    # Copy to black space
    if entity._containerNode
      @black.insertNode(entity._containerNode.remove())
    # Haven't seen it before, add to stage and black space
    else
      @addChild(entity)

    entity.update()

  removed: 0
  sweep: ->
    @removed = 0
    @red.each(@removeChild, @)
    # Swap spaces
    oldRed = @red
    @red = @black
    @black = oldRed
