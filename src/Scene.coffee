class Scene
  constructor: (viewport) ->
    # "from space" for scene removal
    @red = new DLinkedList()
    # "to space" for keeping around
    @black = new DLinkedList()

    window.stage = @stage = new PIXI.Stage(0, false)

    @width = document.body.clientWidth
    @height = window.innerHeight
    @viewport = new Viewport(@width, @height)

    @renderer = PIXI.autoDetectRenderer(@width, @height, document.createElement( 'canvas' ), false, false)
    @renderer.view.style.position = "absolute"
    @renderer.view.style.top = "0px"
    @renderer.view.style.left = "0px"
    document.body.appendChild(@renderer.view)

    @stage.addChild(Tile._displayObjectContainer)
    @stage.addChild(Ship._displayObjectContainer)

  addChild: (object) ->
    if object._displayObject
      object.constructor._displayObjectContainer.addChild(object._displayObject)

    object._sceneNode = @black.insert(object)

  removeChild: (object) ->
    @removed += 1
    if object._displayObject
      object.constructor._displayObjectContainer.removeChild(object._displayObject)

    object._sceneNode.remove()
    object._sceneNode = null

  # TODO: Assumes largest object is 32x32
  objects: 0
  update: ->
    @objects = 0
    @viewport.extent()
    Tile.tree.searchExpand(@viewport._extent, 16, 16, @updateObject, @)
    Ship.tree.searchExpand(@viewport._extent, 16, 16, @updateObject, @)

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

  render: ->
    @renderer.render(@stage)
    @sweep()