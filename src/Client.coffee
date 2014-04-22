# TODO: View needs to be in here? :(
# View = require './views/View'
Scene = require './views/Scene'
DLinkedList = require './models/DLinkedList'
Stats = require './Stats'
Vector2d = require './models/Vector2d'
PIXI = require '../vendor/pixi-1.5.2.dev.js'
Game = require './Game'
Asset = require './views/Asset'
AI = require './models/AI'

BulletView = require './views/BulletView'
EffectView = require './views/EffectView'
ShipView = require './views/ShipView'
TileView = require './views/TileView'

Entity = require("./models/Entity")
Physics = require("./models/Physics")
Ship = require("./models/Ship")
Bullet = require("./models/Bullet")
Tile = require("./models/Tile")
Effect = require("./models/Effect")
AI = require("./models/AI")
Simulator = require("./models/Simulator")
Game = require("./Game")

# TODO: Settings
class Client
  constructor: (game) ->
    @game = game
    @events = []

    @debug = document.getElementById('debug')
    document.addEventListener "keydown", (e) => @keyListen(e, true)
    document.addEventListener "keyup", (e) => @keyListen(e, false)

    window.game = game
    window.client = client = @

    @scene = new Scene(game, @)

    game.register(@)
    # Update screen positions, then render
    game.register(@scene)

    @initStats()
    game.before = => @stats.begin()
    game.after  = => @stats.end()

    @keys = {debugMessages: false}
    @pendingEvents = new DLinkedList
    @serverEvents = []

    @ws = new WebSocket('ws://localhost:8080')
    
    times = {}

    # TODO: Sort out chain of events here and use promises?
    @ws.onopen = (evt) =>
      @send type: 'join'
      console.log("Sent join")
      game.load (bmpData, tiles) =>
        TileView.load(bmpData)
        # client.start()

    @ws.onmessage = (message) =>
      # console.log("#{Date.now()} <-", message)
      ev = JSON.parse(message.data)
      if ev.type == 'connected'
        # great
      else if ev.type == 'joined'
        @receive([ev], true)
        @start()
      else
        @serverEvents.push(ev)

  start: ->
    @game.start(requestAnimationFrame)

  step: (game, timestamp, delta_s) ->
    @receive(@serverEvents)
    @serverEvents = []

    # Events
    # TODO: Clean this
    ev = @newEvent(timestamp, delta_s)
    @pendingEvents.insert(ev, timestamp)
    @send(ev)
    # console.log ev

    # TODO: Better name? Process events?
    @ship.processInput(ev, game.simulator, delta_s)
    

    if @keys.debugCollisions
      @drawDebugCollisions(@ship, game.simulator.collObjs)

    if @keys.debugMessages
      @drawDebug({
        viewport: [@scene.viewport.pos.x, @scene.viewport.pos.y],
        ship: [@ship.pos.x, @ship.pos.y, @ship.rawAngle, @ship.angle],
        shipVel: [@ship.vel.x, @ship.vel.y],
        # viewport: @scene.viewport,
        # map: @map,
        # safety: @ship.safety,
        # safe: @ship.safe,
        # fps: 1/delta_s,
        keys: @keys,
        ev: ev,
        pending: @pendingEvents.count(),
        objects: @scene.objects(),
        collisions: game.simulator.collObjs.length,
        # children: @scene.stage.children.length,
        tiles: @scene.layers["Map"].children.length,
        # ships: @otherShipsLayer.entities,
        projectiles: @scene.layers["Projectiles"].children.length,
        # o: [@othership.pos.x, @othership.pos.y, @othership.rawAngle],
        # simulating: @simulator.objects.length
        # angle: angle
      })

  # TODO: Lifecycle, server id vs local id (or always guid)
  # TODO: Event types, other entities
  receive: (events, firstSync) ->
    for ev in events
      for entityData in ev.entities
        entity = @game.simulator.dynamicEntities.at(entityData.hash)
        if entity
          entity.sync(entityData)
        else
          entity = Entity.deserialize(@game, entityData)
          if entityData.hash == ev.shipHash && firstSync
            @ship = entity
            @ship.player = true
            # TODO: Better way to do this
            @scene.viewport.pos = @ship.pos

      @pendingEvents.each (pev) =>
        if pev.timestamp <= ev.ack
          @pendingEvents.remove(pev.timestamp)
        else
          @ship.processInput(pev)

  send: (ev) ->
    unless ev.timestamp?
      ev.timestamp = Date.now()
    # console.log("#{Date.now()} ->", ev)
    json = JSON.stringify(ev)
    @ws.send(json)

  # TODO: don't keep memory here, flip based on previous event
  keyListen: (e, set = true) ->
    listened = true
    switch e.keyCode
      when KeyEvent.DOM_VK_LEFT then @keys.left = set
      when KeyEvent.DOM_VK_RIGHT then @keys.right = set
      when KeyEvent.DOM_VK_UP then @keys.up = set
      when KeyEvent.DOM_VK_DOWN then @keys.down = set
      when KeyEvent.DOM_VK_S then @keys.fullstop = set
      when KeyEvent.DOM_VK_D then if set then @keys.debug = !@keys.debug
      when KeyEvent.DOM_VK_N then if set then @keys.noclip = !@keys.noclip
      when KeyEvent.DOM_VK_M then if set then @keys.debugMessages = !@keys.debugMessages
      when KeyEvent.DOM_VK_C then if set then @keys.debugCollisions = !@keys.debugCollisions
      when KeyEvent.DOM_VK_SPACE then @keys.fire = set
      else listened = false
    if listened
      e.preventDefault()
      e.stopPropagation()
    console.log @keys

  # TODO: Probably just have dt_s as a field
  newEvent: (timestamp, dt_s) ->
    ev =
      timestamp: timestamp
      x: 0
      y: 0
      fire: 0

    ev.x -= dt_s if @keys.left
    ev.x += dt_s if @keys.right
    ev.y -= dt_s if @keys.down
    ev.y += dt_s if @keys.up

    ev.fire = dt_s if @keys.fire

    ev

  # TODO: Use for network latency?
  initStats: ->
    @stats = new Stats()
    @stats.setMode(0) # 0: fps, 1: ms

    # Align top-left
    @stats.domElement.style.position = 'absolute'
    @stats.domElement.style.right = '0px'
    @stats.domElement.style.top = '0px'
    @stats.domElement.style.zIndex = '10'

    document.body.appendChild( @stats.domElement )

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

    @debug.innerHTML = inspect(obj).join('<br/>')

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

  objects: ->
    sum = 0
    sum += layer.container.children.length for layer in @layers
    sum

# TODO: Is this really the best place for this?
document.addEventListener 'DOMContentLoaded', ->
  console.log "DOMContentLoaded"
  Asset.preload()
  game = new Game
  client = new Client(game)
  # Moved to wait for server connection
  # client.start()

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