# Layer order:
# Starfield
# Map
# Projectiles
# Other ships
# Selfship
# Effects
# HUD
class Scene
  stage: null
  renderer: null
  layers: {}
  layerOrder: [
    "Starfield",
    "Map",
    "Projectiles",
    "Other ships",
    "Selfship",
    "Effects",
    "HUD"
  ]

  constructor: (game, client) ->
    @game = game
    @client = client

    @debug = document.getElementById('debug')

    for name in @layerOrder
      doc = new PIXI.DisplayObjectContainer()
      @stage.addChild(doc)
      layers[name] = doc

    @width = document.body.clientWidth
    @height = window.innerHeight

    @viewport = new Viewport(@width, @height)
    @viewport.pos = game.ship.pos

    @starfield = new Starfield(layers["Starfield"], @viewport)
    @views = {}

  initPixi: ->
    @stage = new PIXI.Stage(0, false)
    @renderer = PIXI.autoDetectRenderer(@width, @height, document.createElement( 'canvas' ), false, false)
    @renderer.view.style.position = "absolute"
    @renderer.view.style.top = "0px"
    @renderer.view.style.left = "0px"
    document.body.appendChild(@renderer.view)
    $(window).resize ->
      @width = document.body.clientWidth
      @height = window.innerHeight
      @renderer.resize(@width, @height)

  step: (game, timestamp, delta_s) ->
    @viewport.extent()
    @starfield.update()

    for hash, view in @views
      view.displayed = false

    game.staticGraph.searchExpand(@viewport._extent, 16, 16, @updateEntity, @)
    game.dynamicGraph.searchExpand(@viewport._extent, 16, 16, @updateEntity, @)
    @renderer.render(@stage)

    for hash, view in @views
      unless view.displayed
        view.remove()
        delete views[hash]

  updateEntity: (entity) ->
    view = @views[entity.hash] ||= View.build(entity)
    updated = view.update(@viewport)
    unless updated
      view.remove()
      delete views[entity.hash]

  objects: ->
    sum = 0
    sum += layer.children.length for name, layer in @layers
    sum