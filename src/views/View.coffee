class View
  doPos: new Vector2d(0,0)
  viewMap = {}
  layerMap = {}
  layer: null
  displayed: false
  hash: 0
  objectCounter = 0

  @extended: (klass, layer) ->
    viewMap[klass.name.replace(/View/, '')] = klass
    layerMap[klass.name] = layer

  # TODO: pool
  @build: (scene, entity) ->
    view = new viewMap[entity.constructor.name](entity)
    layerName = view.layerFor(scene, entity)
    view.layer = scene.layers[layerName]
    view.layer.addChild(view.displayObject)
    view

  constructor: (entity, displayObject) ->
    @entity = entity
    @displayObject = displayObject
    @displayed = false
    @hash = (objectCounter += 1)

  update: (viewport) ->
    return false unless @entity
    return false unless @entity.alive()
    return false unless @displayObject

    @displayed = true

    @doPos.clear().
      add(@entity.pos).
      sub(viewport._extent.ul)

    @displayObject.position.x = @doPos.x
    @displayObject.position.y = @doPos.y

    true

  layerFor: (scene, entity) ->
    layerMap[constructor.name]

  remove: ->
    return true unless @layer
    @layer.removeChild(@displayObject)