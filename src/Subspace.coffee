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
  init: ->
    window.subspace = @

    console.log('init')
    @debug = document.getElementById('debug')

    @keys = {debugMessages: false}
    document.addEventListener "keydown", (e) => @keyListen(e, true)
    document.addEventListener "keyup", (e) => @keyListen(e, false)

    @scene = new Scene()
    @simulator = new Simulator(@scene)

    # Starfield
    # Map
    # Projectiles
    # Other ships
    # Selfship
    # Effects
    # HUD

    @starfield = new Starfield(@scene)

    @mapLayer = @scene.layer("map")
    @map = new Map(@mapLayer)

    @projectileLayer = @scene.layer("projectile")

    @otherShipsLayer = @scene.layer("otherships")
    @othership = new Ship(@otherShipsLayer, @simulator, false, {ship: 1})

    @selfShipLayer = @scene.layer("selfship")
    @ship = new Ship(@selfShipLayer, @simulator, true, {ship: 0, keys: @keys})

    @effectsLayer = @scene.layer("effects")
    
    @scene.viewport.pos = @ship.pos

    @map.load => @start()

  start: ->
    lastTime = 0

    # TODO: profiling
    draw = (ms) =>
      delta = ms - lastTime
      # We stopped the game, just assume a frame
      delta = 16 if delta > 1000
      lastTime = ms
      delta_s = delta / 1000

      # Events
      @handleKeys(delta_s)
      @ship.onKeys(@keys, @simulator, delta_s)

      # Have the other ship follow player (AI?)
      r = Math.sqrt(Math.pow(@ship.pos.x - @othership.pos.x, 2) + Math.pow(@ship.pos.y - @othership.pos.y, 2))
      r -= @ship.w*2
      angle = Math.atan2(@ship.pos.y - @othership.pos.y, @ship.pos.x - @othership.pos.x) + (Math.PI/2)
      @othership.rawAngle = angle/(2*Math.PI)
      @othership.vel.clear().addPolar(r, angle)

      # Run simulation
      @simulator.step(delta_s)

      # Update screen positions
      @scene.update()

      # @drawDebugCollisions(@viewport, @ship, collisions, @onctx)
      if @keys.debugMessages
        @drawDebug({
          ship: [@ship.pos.x, @ship.pos.y, @ship.rawAngle, @ship.angle],
          shipVel: [@ship.vel.x, @ship.vel.y],
          safety: @ship.safety,
          safe: @ship.safe,
          fps: 1/delta * 1000,
          keys: @keys,
          objects: @scene.objects(),
          children: @scene.stage.children.length,
          tiles: @mapLayer.entities,
          ships: @otherShipsLayer.entities,
          projectiles: @projectileLayer.entities,
          o: [@othership.pos.x, @othership.pos.y, @othership.rawAngle],
          simulating: @simulator.objects.length
          # angle: angle
        })

      @scene.render()
      requestAnimationFrame(draw)
    draw(lastTime)

  # TODO: Use webgl text instead of element, faster?
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
            rep = JSON.stringify(v)
            if rep == 'null'
              rep = v.toString()
            str += rep
        str

    $(@debug).html(inspect(obj).join('<br/>'))

  # TODO: Use pixi
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

  # TODO: emit events
  keyListen: (e, set = true) ->
    listened = true
    switch e.keyCode
      when KeyEvent.DOM_VK_LEFT then @keys.left = set
      when KeyEvent.DOM_VK_RIGHT then @keys.right = set
      when KeyEvent.DOM_VK_UP then @keys.up = set
      when KeyEvent.DOM_VK_DOWN then @keys.down = set
      when KeyEvent.DOM_VK_S then @keys.fullstop = set
      when KeyEvent.DOM_VK_D then @keys.debugger = set
      when KeyEvent.DOM_VK_N then if set then @keys.noclip = !@keys.noclip
      when KeyEvent.DOM_VK_M then if set then @keys.debugMessages = !@keys.debugMessages
      when KeyEvent.DOM_VK_SPACE then @keys.fire = set
      else listened = false
    if listened
      e.preventDefault()
      e.stopPropagation()

  handleKeys: (delta) ->
    if @keys.debugger
      @keys.debugger = false
      debugger

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