# TODO: View needs to be in here? :(
# View = require './views/View'
Scene = require './views/Scene'
DLinkedList = require './models/DLinkedList'
Stats = require './Stats'
Vector2d = require './models/Vector2d'
PIXI = require '../vendor/pixi.js/bin/pixi.dev.js'
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

WST = require("./network/WebSocketTransport")

# TODO: Settings
class Client
  pendingEvents: new DLinkedList

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

    @keys = {debugMessages: false}

    @network = WST.default("ws://#{window.location.hostname}:8080")

    # connect
    # -> join
    # <- connected
    # <- joined (with first ship event sync)
    # -> keys keys keys
    # <- gamestate gamestate gamestate
    @network.on "open", =>
      @network.enqueue(type: 'join', shipType: Math.random() * 8 | 0)
      @network.flush()
      console.log("[Client] Sent join")
      game.load (bmpData, tiles) =>
        TileView.load(bmpData)

    @network.on "close", ->
      console.log("[Client] Disconnected")

    @network.on "connected", ->
      console.log("[Client] Connected")

    @network.on "joined", (ev) =>
      console.log("[Client] Joined")
      @ship = Entity.deserialize(@game, ev.ship)
      @ship.player = true
      # TODO: Better way to do this
      @scene.viewport.pos = @ship.pos
      @start()
      @network.enqueue(type: 'gamestart')

    @network.on "pong", (ev) =>
      # console.log("[Client] PONG", game.last, ev.ack, game.last - ev.ack, Date.now())
      @latency.frame((game.last | 0) - ev.ack, Date.now())

    # Then flush what's in the queue
    game.register(@network)

    setInterval =>
      @network.enqueue(type: "ping", timestamp: game.last | 0)
    , 1000

  start: ->
    @game.start(requestAnimationFrame)

  step: (game, timestamp, delta_s) ->
    if window.subspacePlaybacking
      debugger;
      while (window.subspacePlaybackLog[window.subspacePlaybackIndex].timestamp + window.subspacePlaybackOffset) < timestamp
        pev = window.subspacePlaybackLog[window.subspacePlaybackIndex]
        @ship.processInput(pev)
        window.subspacePlaybackIndex++
    else
      @network.receive (ev) =>
        @receive(ev)

      # Events
      ev = @newEvent(timestamp|0, delta_s)
      @pendingEvents.insert(ev, ev.timestamp)
      if window.subspaceRecording
        window.subspaceRecordingLog.push(ev)
      @network.enqueue(ev)

      # TODO: Better name? Process events?
      # TODO: When disconnected?
      @ship.processInput(ev, game.simulator, delta_s)

    if @keys.debugCollisions
      @drawDebugCollisions(@ship, game.simulator.collObjs)

    if @keys.debugMessages
      @drawDebug({
        connected: @connected,
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
        lastEvent: @lastEvent,
        objects: @scene.objects(),
        collisions: game.simulator.collObjs.length,
        # children: @scene.stage.children.length,
        tiles: @scene.layers["Map"].children.length,
        # ships: @otherShipsLayer.entities,
        projectiles: @scene.layers["Projectiles"].children.length,
        recording: window.subspaceRecording,
        recordingL: window.subspaceRecordingLog?.length,
        playbacking: window.subspacePlaybacking,
        playbackL: window.subspacePlaybackLog?.length,
        playbackIndex: window.subspacePlaybackIndex,
        playbackOffset: window.subspacePlaybackOffset,
        playbackFirst: window.subspacePlaybackLog?[0].timestamp,
        playbackGameLast: window.subspacePlaybackGameLast
        # o: [@othership.pos.x, @othership.pos.y, @othership.rawAngle],
        # simulating: @simulator.objects.length
        # angle: angle
      })

  # TODO: Lifecycle, server id vs local id (or always guid)
  # TODO: Event types, other entities
  diff = new Vector2d
  receive: (ev) ->
    @lastEvent = ev
    # console.log("[Client] ack:", ev.ack, ev.timestamp)
    for entityData in ev.entities
      entity = @game.simulator.dynamicEntities.at(entityData.hash)
      if entity
        entity.sync(entityData)
      else
        entity = Entity.deserialize(@game, entityData)

      if entityData.hash == ev.shipHash
        # TODO: If we receive out of order?
        @pendingEvents.each (pev) =>
          if pev.timestamp <= ev.ack
            @pendingEvents.remove(pev.timestamp)
          else
            @ship.processInput(pev)
        diff.clear().add(@ship.lastPos).sub(@ship.pos)
        debugger if @keys.debug;
        err = Math.floor(diff.length() * 100)
        @errorStats.frame(err, Date.now())

  # TODO: don't keep memory here, flip based on previous event
  keyListen: (e, set = true) ->
    @keys.listened = true
    switch e.keyCode
      when KeyEvent.DOM_VK_LEFT then @keys.left = set
      when KeyEvent.DOM_VK_RIGHT then @keys.right = set
      when KeyEvent.DOM_VK_UP then @keys.up = set
      when KeyEvent.DOM_VK_DOWN then @keys.down = set
      when KeyEvent.DOM_VK_SPACE then @keys.fire = set

      when KeyEvent.DOM_VK_S then @ws.close()
      when KeyEvent.DOM_VK_D then if set then @keys.debug = !@keys.debug
      when KeyEvent.DOM_VK_N then if set then @keys.noclip = !@keys.noclip
      when KeyEvent.DOM_VK_M then if set then @keys.debugMessages = !@keys.debugMessages
      when KeyEvent.DOM_VK_C then if set then @keys.debugCollisions = !@keys.debugCollisions
      when KeyEvent.DOM_VK_R
        if set
          if window.subspaceRecording
            window.subspaceRecordingLog.push({
              type: "gamestate",
              timestamp: @game.last,
              entities: @game.state(@ship)
            })
            # Send this to the FS
            window.subspaceRecording = false
            blob = new Blob([JSON.stringify(window.subspaceRecordingLog)], {type: "text/json"})
            saveAs(blob, "subspace_#{ @game.last }.log")
          else
            window.subspaceRecordingLog = [{
              type: "gamestate",
              timestamp: @game.last,
              entities: @game.state(@ship)
            }]
            window.subspaceRecording = true
      when KeyEvent.DOM_VK_P
        game = @game
        keys = @keys
        if set
          change = (e) ->
            file = e.target.files[0]
            reader = new FileReader()
            reader.onload = (oe) ->
              contents = oe.target.result
              window.subspacePlaybackLog = JSON.parse(contents)
              stateEv = window.subspacePlaybackLog[0]
              window.subspacePlaybackGameLast = game.last
              window.subspacePlaybackOffset = game.last - stateEv.timestamp
              for entityData in stateEv.entities
                entity = game.simulator.dynamicEntities.at(entityData.hash)
                if entity
                  entity.sync(entityData)
                else
                  entity = Entity.deserialize(game, entityData)

              window.subspacePlaybackIndex = 1
              window.subspacePlaybacking = true
              keys.debugMessages = true
            reader.readAsText(file)
          document.getElementById("recording_log_input").addEventListener('change', change, false)
          document.getElementById("recording_log_input").click()

      else @keys.listened = false
    if @keys.listened
      e.preventDefault()
      e.stopPropagation()
      if @keys.debug
        window.keysDebug = true
      else
        window.keysDebug = false
    # console.log @keys

  # TODO: Probably just have dt_s as a field
  newEvent: (timestamp, dt_s) ->

    dt_s_r = Math.floor(dt_s * 1000)/1000

    ev =
      timestamp: timestamp | 0
      type: "keys"
      x: 0
      y: 0
      fire: 0

    ev.x -= dt_s_r if @keys.left
    ev.x += dt_s_r if @keys.right
    ev.y -= dt_s_r if @keys.down
    ev.y += dt_s_r if @keys.up

    ev.fire = dt_s_r if @keys.fire

    ev

  initStats: ->
    @stats = new Stats()
    @stats.setMode(0) # 0: fps, 1: ms

    # Align top-right
    @stats.domElement.style.position = 'absolute'
    @stats.domElement.style.right = '0px'
    @stats.domElement.style.top = '0px'
    @stats.domElement.style.zIndex = '10'

    document.body.appendChild( @stats.domElement )

    game.before = => @stats.begin()
    game.after  = => @stats.end()

    @latency = new Stats()
    @latency.setMode(1)

    # Align top-right below fps
    @latency.domElement.style.position = 'absolute'
    @latency.domElement.style.right = '0px'
    @latency.domElement.style.top = '50px'
    @latency.domElement.style.zIndex = '10'

    document.body.appendChild( @latency.domElement )

    @errorStats = window.errorStats = new Stats()
    @errorStats.setMode(1)

    # Align top-right below fps
    @errorStats.domElement.style.position = 'absolute'
    @errorStats.domElement.style.right = '0px'
    @errorStats.domElement.style.top = '100px'
    @errorStats.domElement.style.zIndex = '10'

    document.body.appendChild( @errorStats.domElement )

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

  objects: ->
    sum = 0
    sum += layer.container.children.length for layer in @layers
    sum

# TODO: Is this really the best place for this?
document.addEventListener 'DOMContentLoaded', ->
  console.log "[Client] DOMContentLoaded"
  Asset.preload()
  game = new Game
  client = new Client(game)
  console.log("[Client]", client.scene)
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
