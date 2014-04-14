require ["main"], ->
  console.log("main.js loaded")
  debugger
  require([
    "vendor/pixi-1.5.2.dev.js",
    "vendor/jquery-2.0.3.js",
    "vendor/bmpimage/bmpimage2.js",
    "vendor/stats.min.js",
    "lib/views/View.js",
    "lib/views/Asset.js"
    "lib/views/BulletView.js",
    "lib/views/Scene.js",
    "lib/views/Map.js",
    "lib/views/Viewport.js",
    "lib/views/TileView.js",
    "lib/views/ShipView.js",
    "lib/views/EffectView.js",
    "lib/views/Starfield.js",
    "lib/Client.js",
  ], (pixi) ->
    window.PIXI = pixi
    console.log("browser.js loaded")

    Asset.preload()
    game = new Game
    client = new Client(game)
    client.start()

    document.addEventListener 'DOMContentLoaded', ->
      console.log "DOMContentLoaded"
  )