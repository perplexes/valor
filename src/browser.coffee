require([
  "vendor/jquery-2.0.3.js",
  "vendor/bmpimage/bmpimage2.js",
  "vendor/pixi-1.5.2.dev.js",
  "vendor/stats.min.js",
  "main",
  "lib/views/Effect.js",
], ->
  document.addEventListener 'DOMContentLoaded', ->
    console.log "DOMContentLoaded"
    game = new Subspace
    client = new Client(game)
    client.start()
)