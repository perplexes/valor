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
  views: {}
  debug: document.getElementById('debug')
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

    @initPixi()

    for name in @layerOrder
      doc = new PIXI.DisplayObjectContainer()
      @stage.addChild(doc)
      @layers[name] = doc

    @width = document.body.clientWidth
    @height = window.innerHeight

    @viewport = new Viewport(@width, @height)
    @viewport.pos = game.ship.pos

    @starfield = new Starfield(@layers["Starfield"], @viewport)

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

    for hash, view of @views
      view.displayed = false

    game.simulator.staticTree.searchExpand(@viewport._extent, 16, 16, @buildView, @)
    game.simulator.dynamicTree.searchExpand(@viewport._extent, 16, 16, @buildView, @)

    for hash, view of @views
      updated = view.update(@viewport)
      unless view.displayed && updated
        view.remove()
        delete @views[hash]

    @renderer.render(@stage)

  buildView: (entity) ->
    view = @views[entity.hash]
    unless view
      view = View.build(@, entity)
      return unless view.displayObject
      @views[entity.hash] = view

    if view
      view.displayed = true

  objects: ->
    sum = 0
    sum += layer.children.length for name, layer of @layers
    sum