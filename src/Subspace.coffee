# require [
#   "../vendor/restruct",
#   "../vendor/jParser/src/jparser",
#   "../vendor/bmpimage/bmpimage2",
#   "../vendor/js_bintrees"
# ]
`
Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};
`

class Subspace
  canvas: (id) ->
    c = document.getElementById(id)
    c.width = c.style.width = document.body.clientWidth
    c.height = c.style.height = window.innerHeight
    [c, c.getContext('2d')]

  init: ->
    console.log('init')
    [@offscreen, @offctx] = @canvas('offscreen')
    [@onscreen, @onctx] = @canvas('onscreen')
    @debug = document.getElementById('debug')

    @viewport =
      width: onscreen.clientWidth
      height: onscreen.clientHeight

    @tiles = []
    @keys = {} # old -> new

    document.addEventListener "keydown", (e) => @keyListen(e, true)
    document.addEventListener "keyup", (e) => @keyListen(e, false)

    @shipImage = new Image()
    @shipImage.src = "assets/ship2.png" # 170x166
    @shipImage.width = 170
    @shipImage.height = 166

    @ship =
      angle: 0
      # Near circles
      # x: 513 * 16
      # y: 397 * 16
      # Safety
      # x: 8196
      # y: 12135
      x: 8197
      y: 11986
      dx: 0
      dy: 0
      w: 170/4
      h: 166/4
      maxSpeed: 500

    @starfield = new Starfield()

    oReq = new XMLHttpRequest()
    oReq.open "GET", "../arenas/trench9.lvl", true
    oReq.responseType = "arraybuffer"
    oReq.onload = (oEvent) =>
      @map = new Map(oEvent)
      @start()

    oReq.send null

  start: ->
    lastTime = 0
    draw = (ms) =>
      delta = ms - lastTime
      # We stopped the game, just assume a frame
      delta = 16 if delta > 1000
        

      lastTime = ms
      # @offctx.clearRect(0, 0, @offscreen.width, @offscreen.height)
      # TODO: Only draw if it's changed from the last frame
      @onctx.clearRect(0, 0, @onscreen.width, @onscreen.height)

      # Events
      @handleKeys(delta)

      tiles = @map.tilesInView(@viewport, @ship)

      # Simulation
      collisions = @simulateShip(delta, @ship, tiles)

      # Draw
      sfdraw = @starfield.draw(@viewport, @ship, @onctx)
      @map.draw(@viewport, @ship, tiles, @onctx)
      @drawShip(@onctx)
      # @drawDebugCollisions(@viewport, @ship, collisions, @onctx)
      # @drawDebug({
      #   ship: @ship,
      #   stars: sfdraw,
      #   tiles: tiles.length,
      #   collisions: collisions.length,
      #   fps: 1/delta * 1000
      # })

      # @onctx.drawImage(@offscreen, 0, 0)
      requestAnimationFrame(draw)
    draw(lastTime)

  drawShip: (ctx) ->
    ctx.save()
    ctx.translate(@viewport.width/2, @viewport.height/2)
    ctx.scale(0.25, 0.25)
    ctx.rotate(@ship.angle)
    ctx.drawImage(@shipImage, -170/2, -166/2)
    ctx.restore()

  drawDebug: (obj) ->
    inspect = (o, d=0, omitKey=false) ->
      return ['...'] if d >= 5

      for k, v of o
        str = if omitKey then "" else "#{k}: "
        if k.indexOf("_") != -1
          str += "<#{k}>"
        else
          if typeof(v) == "object"
            if Array.isArray(v)
              str += "[#{inspect(v, d+1, true).join(', ')}]"
            else # is Object
              str += "{#{inspect(v, d+1).join(', ')}}"
          else
            str += JSON.stringify(v)
        str

    $(@debug).html(inspect(obj).join('<br/>'))

  drawDebugCollisions: (viewport, ship, tiles, ctx) ->
    origin =
      x: ship.x - viewport.width / 2
      y: ship.y - viewport.height / 2

    for tile in tiles
      ctx.save()
      ctx.fillStyle = "rgba(255, 0, 0, 0.5)"
      x = tile.min.x - origin.x
      y = tile.min.y - origin.y
      ctx.fillRect(x, y, 16, 16)
      ctx.restore()

    ctx.save()
    ctx.fillStyle = "rgba(0,255,0,0.5)"
    ctx.fillRect(
      ship.x - ship.w / 2 - origin.x,
      ship.y - ship.h / 2 - origin.y,
      ship.w,
      ship.h
    )
    ctx.restore()

  simulateShip: (delta, ship, nearTiles) ->
    @ship.x += @ship.dx * (delta / 1000)
    @ship.y += @ship.dy * (delta / 1000)
    @ship.x = @ship.x.clamp(0, 1024 * 16)
    @ship.y = @ship.y.clamp(0, 1024 * 16)


    collisions = []
    
    ship.min =
      x: ship.x - ship.w/2
      y: ship.y - ship.h/2
    ship.max =
      x: ship.x + ship.w/2
      y: ship.y + ship.h/2

    for tile in nearTiles
      if Physics.collision(ship, tile)
        collisions.push tile
        if m = Physics.overlap(ship, tile)
          if resolution = Physics.resolve(ship, tile, m)
            ship.x += resolution.a[0]
            ship.y += resolution.a[1]
            ship.dx += resolution.a[2]
            ship.dy += resolution.a[3]

    # if collisions.length > 0
    #   for tile in collisions

    #       # Skip b resolution for now - tiles are immovable

    @ship.tx = @ship.x / 16
    @ship.ty = @ship.y / 16

    collisions

  keyListen: (e, set = true) ->
    listened = true
    switch e.keyCode
      when KeyEvent.DOM_VK_LEFT then @keys.left = set
      when KeyEvent.DOM_VK_RIGHT then @keys.right = set
      when KeyEvent.DOM_VK_UP then @keys.up = set
      when KeyEvent.DOM_VK_DOWN then @keys.down = set
      when KeyEvent.DOM_VK_S then @keys.fullstop = set
      when KeyEvent.DOM_VK_D then @keys.debugger = set
      else listened = false
    if listened
      e.preventDefault()
      e.stopPropagation()

  handleKeys: (delta) ->
    if @keys.debugger
      @keys.debugger = false
      debugger

    x = 0
    x -= 1 if @keys.left
    x += 1 if @keys.right 

    y = 0
    y += 1 if @keys.up
    y -= 1 if @keys.down

    @ship.angle += (Math.PI * 1.4) * (delta / 1000) * x
    @ship.dx += 400 * Math.sin(@ship.angle) * (delta / 1000) * y
    @ship.dy -= 400 * Math.cos(@ship.angle) * (delta / 1000) * y
    @ship.dx = @ship.dx.clamp(-@ship.maxSpeed, @ship.maxSpeed)
    @ship.dy = @ship.dy.clamp(-@ship.maxSpeed, @ship.maxSpeed)

    if @keys.fullstop
      @ship.dx = @ship.dy = 0

if (typeof KeyEvent == "undefined")
  KeyEvent =
    DOM_VK_CANCEL: 3,
    DOM_VK_HELP: 6,
    DOM_VK_BACK_SPACE: 8,
    DOM_VK_TAB: 9,
    DOM_VK_CLEAR: 12,
    DOM_VK_RETURN: 13,
    DOM_VK_ENTER: 14,
    DOM_VK_SHIFT: 16,
    DOM_VK_CONTROL: 17,
    DOM_VK_ALT: 18,
    DOM_VK_PAUSE: 19,
    DOM_VK_CAPS_LOCK: 20,
    DOM_VK_ESCAPE: 27,
    DOM_VK_SPACE: 32,
    DOM_VK_PAGE_UP: 33,
    DOM_VK_PAGE_DOWN: 34,
    DOM_VK_END: 35,
    DOM_VK_HOME: 36,
    DOM_VK_LEFT: 37,
    DOM_VK_UP: 38,
    DOM_VK_RIGHT: 39,
    DOM_VK_DOWN: 40,
    DOM_VK_PRINTSCREEN: 44,
    DOM_VK_INSERT: 45,
    DOM_VK_DELETE: 46,
    DOM_VK_0: 48,
    DOM_VK_1: 49,
    DOM_VK_2: 50,
    DOM_VK_3: 51,
    DOM_VK_4: 52,
    DOM_VK_5: 53,
    DOM_VK_6: 54,
    DOM_VK_7: 55,
    DOM_VK_8: 56,
    DOM_VK_9: 57,
    DOM_VK_SEMICOLON: 59,
    DOM_VK_EQUALS: 61,
    DOM_VK_A: 65,
    DOM_VK_B: 66,
    DOM_VK_C: 67,
    DOM_VK_D: 68,
    DOM_VK_E: 69,
    DOM_VK_F: 70,
    DOM_VK_G: 71,
    DOM_VK_H: 72,
    DOM_VK_I: 73,
    DOM_VK_J: 74,
    DOM_VK_K: 75,
    DOM_VK_L: 76,
    DOM_VK_M: 77,
    DOM_VK_N: 78,
    DOM_VK_O: 79,
    DOM_VK_P: 80,
    DOM_VK_Q: 81,
    DOM_VK_R: 82,
    DOM_VK_S: 83,
    DOM_VK_T: 84,
    DOM_VK_U: 85,
    DOM_VK_V: 86,
    DOM_VK_W: 87,
    DOM_VK_X: 88,
    DOM_VK_Y: 89,
    DOM_VK_Z: 90,
    DOM_VK_CONTEXT_MENU: 93,
    DOM_VK_NUMPAD0: 96,
    DOM_VK_NUMPAD1: 97,
    DOM_VK_NUMPAD2: 98,
    DOM_VK_NUMPAD3: 99,
    DOM_VK_NUMPAD4: 100,
    DOM_VK_NUMPAD5: 101,
    DOM_VK_NUMPAD6: 102,
    DOM_VK_NUMPAD7: 103,
    DOM_VK_NUMPAD8: 104,
    DOM_VK_NUMPAD9: 105,
    DOM_VK_MULTIPLY: 106,
    DOM_VK_ADD: 107,
    DOM_VK_SEPARATOR: 108,
    DOM_VK_SUBTRACT: 109,
    DOM_VK_DECIMAL: 110,
    DOM_VK_DIVIDE: 111,
    DOM_VK_F1: 112,
    DOM_VK_F2: 113,
    DOM_VK_F3: 114,
    DOM_VK_F4: 115,
    DOM_VK_F5: 116,
    DOM_VK_F6: 117,
    DOM_VK_F7: 118,
    DOM_VK_F8: 119,
    DOM_VK_F9: 120,
    DOM_VK_F10: 121,
    DOM_VK_F11: 122,
    DOM_VK_F12: 123,
    DOM_VK_F13: 124,
    DOM_VK_F14: 125,
    DOM_VK_F15: 126,
    DOM_VK_F16: 127,
    DOM_VK_F17: 128,
    DOM_VK_F18: 129,
    DOM_VK_F19: 130,
    DOM_VK_F20: 131,
    DOM_VK_F21: 132,
    DOM_VK_F22: 133,
    DOM_VK_F23: 134,
    DOM_VK_F24: 135,
    DOM_VK_NUM_LOCK: 144,
    DOM_VK_SCROLL_LOCK: 145,
    DOM_VK_COMMA: 188,
    DOM_VK_PERIOD: 190,
    DOM_VK_SLASH: 191,
    DOM_VK_BACK_QUOTE: 192,
    DOM_VK_OPEN_BRACKET: 219,
    DOM_VK_BACK_SLASH: 220,
    DOM_VK_CLOSE_BRACKET: 221,
    DOM_VK_QUOTE: 222,
    DOM_VK_META: 224

document.addEventListener 'DOMContentLoaded', ->
  console.log "DOMContentLoaded"
  (new Subspace).init()