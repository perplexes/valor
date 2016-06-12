restruct = require("restruct")
jParser = require('jParser')
# RBTree = require('bintrees').RBTree
Vector2d = require("./models/Vector2d")
DLinkedList = require("./models/DLinkedList")
ArrayTree = require("./models/ArrayTree")
Extent = require("./models/Extent")
# UBTree = require("./models/UBTree")
RbushTree = require("./models/RbushTree")

Entity = require("./models/Entity")
Physics = require("./models/Physics")
Ship = require("./models/Ship")
Bullet = require("./models/Bullet")
Tile = require("./models/Tile")
Effect = require("./models/Effect")
AI = require("./models/AI")
Simulator = require("./models/Simulator")
Game = require("./Game")

WebSocketServerTransport = require("./network/WebSocketServerTransport")

pnow = require("performance-now")

`
Math.rand = function(min, max) {
  return (Math.random() * max | 0) + min;
}
`

class Server
  frequency: 32 # ms
  constructor: ->
    @entities = {}

    wsst = new WebSocketServerTransport({port: 8080})
    wsst.onConnection (client) =>
      client.enqueue(type: "connected")
      client.on "close", (data) =>
        console.log("[Server] Disconnected:", client)
        @disconnect(client)

      client.on "ping", (data) =>
        client.enqueue(type: "pong", ack: data.timestamp)

      client.on "join", (ev) =>
        console.log("[Server] Join:", ev.shipType)
        ship = new Ship(@game.simulator, false, {ship: ev.shipType || 0})
        @entities[client] = ship
        client.meta.joined = true
        client.enqueue(type: "joined", ship: ship.serialize())
        client.flush()

        client.on "gamestart", (ev) =>
          # TODO: adaptive jitter buffer
          # TODO: reorder packets
          client.on "receive", (client) =>
            return unless client.connected

            client.receive (ev) =>
              # console.log("[Server] receive", ev)
              ship.processInput(ev)
              client.meta.ack = ev.timestamp

          client.on "step", (client) =>
            if client.connected
              @sendGameState(client, ship)
            else
              ship.expireNow()
              delete @entities[client]


    @game = new Game
    @game.register(@)
    @game.register(wsst)

    # for i in [0..400]
    #   ship = new Ship(@game.simulator, false, {ship: 0})
    #   x = Math.rand(-i*16, i*16)
    #   y = Math.rand(-i*16, i*16)
    #   ship.pos.addXY(x, y)
    #   dx = Math.rand(-100, 100)
    #   dy = Math.rand(-100, 100)
    #   ship.vel.addXY(dx, dy)

    samples = []
    sampleStart = pnow()
    @game.before = =>
      sampleStart = pnow()
      # console.log('Tick')
    @game.after = =>
      samples.push(pnow() - sampleStart)

    setInterval ->
      a = 0
      for i in samples
        a += i
      avg = a/samples.length

      samples = []
      console.log("[Server]", avg * 1000 | 0, "us")
    , 1000

    @game.load (bmpData, tiles) =>
      console.log("[Server] @game.load")
      @start()

  requestServerTick: (next) =>
    now = Date.now()
    delta_ms =  now - @last
    # console.log(@last, Date.now(), delta_ms)
    if delta_ms >= @frequency
      callback = => next(now - @started)
      setTimeout callback, 0
      @last = now
    else
      callback = => @requestServerTick(next)
      setTimeout callback, @frequency - delta_ms

  start: =>
    @last = @started = Date.now()
    @game.start(@requestServerTick)

  step: (game, timestamp, delta_s) ->
    # Handled by network code?

  sendGameState: (client, ship) ->
    # console.log("[Server] sendGameState", client.meta.ack)
    output =
      shipHash: ship.hash
      entities: @game.state(ship)
      ack: client.meta.ack
      type: "gamestate"
    client.enqueue(output)

  # TODO: Sweep the simulator and other trees here
  # Unless the simulator is responsible for that
  disconnect: (client, ship) ->
    console.log "[Server] Disconnecting:", client


window.server = new Server
