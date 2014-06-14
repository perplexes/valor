restruct = require("restruct")
jParser = require('jParser')
RBTree = require('bintrees').RBTree
Vector2d = require("./models/Vector2d")
DLinkedList = require("./models/DLinkedList")
ArrayTree = require("./models/ArrayTree")
Extent = require("./models/Extent")
ZTree = require("./models/ZTree")
        
Entity = require("./models/Entity")
Physics = require("./models/Physics")
Ship = require("./models/Ship")
Bullet = require("./models/Bullet")
Tile = require("./models/Tile")
Effect = require("./models/Effect")
AI = require("./models/AI")
Simulator = require("./models/Simulator")
Game = require("./Game")

pnow = require("performance-now")

WebSocketServer = require('ws').Server
class Server
  frequency: 32 # ms
  constructor: ->
    @clientEvents = []
    @clients = new DLinkedList
    console.log @clients
    @clientCount = 0
    @entities = {}
    @clientMeta = {}

    @wss = new WebSocketServer({port: 8080});
    @wss.on 'connection', (ws) =>
      client = @clientCount++
      @clients.insert(ws, client)
      meta = @clientMeta[client] = {}
      console.log("Connected:", client)
      @send(ws, client, {type: 'connected'})

      ws.on 'message', (json) =>
        ev = JSON.parse(json)
        ev.client = client
        meta.ack = ev.timestamp
        if ev.type == "join"
          ship = new Ship(@game.simulator, false, {ship: 0})
          @entities[client] = ship
          @sendGameState(ws, @game, client)
        else
          meta.joined = true
          @clientEvents.push ev

      ws.on 'close', => @disconnect(client)

    @game = new Game
    @game.register(@)
    @game.after = =>
      # console.log('Simulated:', @game.simulator.simulated.length)
    # @game.before = ->
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
      console.log(avg * 1000 | 0, "us")
    , 1000

    @game.load (bmpData, tiles) =>
      console.log("@game.load")
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
    @receive(@clientEvents)
    @clientEvents = []
    @clients.each (ws, client) =>
      if @clientMeta[client] && @clientMeta[client].joined
        @sendGameState(ws, game, client)

  # TODO: a receive on a WS should verify client_id belongs to it
  receive: (events) ->
    for ev in events
      if @clients.at(ev.client)
        # console.log "#{Date.now()} <-", ev
        @entities[ev.client].processInput(ev)
      # switch on type? handlers?

  sendGameState: (ws, game, client) ->
    type = if @clientMeta[client].joined then 'update' else 'joined'
    output =
      shipHash: @entities[client].hash
      entities: game.state(@entities[client])
      ack: @clientMeta[client].ack
      type: type
    @send(ws, client, output)

  send: (ws, client, obj) ->
    return @disconnect(client) unless ws.readyState == 1
    obj.timestamp = Date.now()
    json = JSON.stringify(obj)
    # console.log("#{Date.now()} ->", json)
    ws.send(json)

  disconnect: (client) ->
    return unless @clients.at(client)
    @clients.remove(client)
    delete @clientMeta[client]
    entity = @entities[client]
    delete @entities[client]
    entity.expire()

connect = require("connect")
connect().use(connect.static(__dirname + "../../")).listen(8000)
new Server
