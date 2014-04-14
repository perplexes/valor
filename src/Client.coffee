# TODO: Settings
class Client
  constructor: (game) ->
    @game = game
    @events = []

    document.addEventListener "keydown", (e) => @keyListen(e, true)
    document.addEventListener "keyup", (e) => @keyListen(e, false)

    @scene = new Scene(game, @)

    game.register(new AI)
    game.register(@)
    # Update screen positions, then render
    game.register(@scene)

    game.before = => @stats.begin()
    game.after  = => @stats.end()

    @keys = {debugMessages: false}

    game.load (bmpData, tiles) ->
      TileView.load(bmpData)

  start: ->
    @game.step(0, requestAnimationFrame)

  step: (game, timestamp, delta_s) ->
    # Events
    # TODO: Clean this
    @events.push event(timestamp)

    # TODO: Better name? Process events?
    @game.ship.onKeys(@keys, @game.simulator, delta_s)

    if @keys.debugCollisions
      @drawDebugCollisions(@game.ship, @game.simulator.collisions)

    if @keys.debugMessages
      @drawDebug({
        ship: [@ship.pos.x, @ship.pos.y, @ship.rawAngle, @ship.angle],
        shipVel: [@ship.vel.x, @ship.vel.y],
        # viewport: @scene.viewport,
        # map: @map,
        # safety: @ship.safety,
        # safe: @ship.safe,
        fps: 1/delta_s,
        keys: @keys,
        objects: @scene.objects(),
        children: @scene.stage.children.length,
        tiles: @mapLayer.entities,
        ships: @otherShipsLayer.entities,
        projectiles: @projectileLayer.entities,
        # o: [@othership.pos.x, @othership.pos.y, @othership.rawAngle],
        # simulating: @simulator.objects.length
        # angle: angle
      })

  objects: ->
    sum = 0
    sum += layer.container.children.length for layer in @layers
    sum

  # TODO: Use webgl text instead of element, faster?
  # TODO: Put in scene perhaps? Or a debug layer?
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

  adjPoint = new Vector2d
  drawDebugCollisions: (ship, objects) ->
    unless @collisionGraphics
      @collisionGraphics = new PIXI.Graphics
      @scene.stage.addChild(@collisionGraphics)

    @collisionGraphics.clear()
    graphics = @collisionGraphics

    # graphics.beginFill(0x0000FF)
    # graphics.drawRect(0,0,50,50)
    # graphics.endFill()

    # Tile color
    graphics.beginFill(0xFF0000, 0.5)

    for object in objects
      adjPoint.clear().add(object._extent.ul).sub(@scene.viewport._extent.ul)
      graphics.drawRect(adjPoint.x, adjPoint.y, object.w, object.h)

    graphics.endFill()

    # Ship color
    graphics.beginFill(0x00FF00, 0.5)

    adjPoint.clear().add(ship._extent.ul).sub(@scene.viewport._extent.ul)
    graphics.drawRect(adjPoint.x, adjPoint.y, ship.w, ship.h)

    graphics.endFill()
    debugger if @keys.debugger


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
      when KeyEvent.DOM_VK_C then if set then @keys.debugCollisions = !@keys.debugCollisions
      when KeyEvent.DOM_VK_SPACE then @keys.fire = set
      else listened = false
    if listened
      e.preventDefault()
      e.stopPropagation()

  event: (timestamp) ->
    timestamp: timestamp,
    left: @keys.left,
    right: @keys.right,
    up: @keys.up,
    down: @keys.down,
    fire: @keys.fire

  initStats: ->
    @stats = new Stats()
    @stats.setMode(0) # 0: fps, 1: ms

    # Align top-left
    @stats.domElement.style.position = 'absolute'
    @stats.domElement.style.right = '0px'
    @stats.domElement.style.top = '0px'
    @stats.domElement.style.zIndex = '10'

    document.body.appendChild( @stats.domElement )

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