class Scene
  constructor: (viewport) ->
    @layers = []

    window.stage = @stage = new PIXI.Stage(0, false)

    @width = document.body.clientWidth
    @height = window.innerHeight
    @viewport = new Viewport(@width, @height)

    @renderer = PIXI.autoDetectRenderer(@width, @height, document.createElement( 'canvas' ), false, false)
    @renderer.view.style.position = "absolute"
    @renderer.view.style.top = "0px"
    @renderer.view.style.left = "0px"
    document.body.appendChild(@renderer.view)

  # Layer interface: responds to update/sweep/container
  addLayer: (layer) ->
    @layers.push layer
    @stage.addChild(layer.container)

  update: ->
    @viewport.extent()
    layer.update() for layer in @layers
    null

  render: ->
    @renderer.render(@stage)
    layer.sweep() for layer in @layers
    null

  objects: ->
    sum = 0
    sum += layer.container.children.length for layer in @layers
    sum