restruct = require("restruct")
# jDataView = require("../vendor/jDataView/src/jDataView.js")
jParser = require('jParser')
RBTree = require('bintrees').RBTree
Vector2d = require("./models/Vector2d.js")
DLinkedList = require("./models/DLinkedList.js")
ArrayTree = require("./models/ArrayTree.js")
Extent = require("./models/Extent.js")
ZTree = require("./models/ZTree.js")
        
Entity = require("./models/Entity.js")
Physics = require("./models/Physics.js")
Ship = require("./models/Ship.js")
Bullet = require("./models/Bullet.js")
Tile = require("./models/Tile.js")
Effect = require("./models/Effect.js")
AI = require("./models/AI.js")
Simulator = require("./models/Simulator.js")
Entity = require("./models/Entity.js")
Game = require("./Game.js")

WebSocketServer = require('ws').Server
class Server
  frequency: 100 # ms
  constructor: ->
    @clientEvents = []
    @clients = new DLinkedList
    @clientCount = 0

    @wss = new WebSocketServer({port: 8080});
    @wss.on 'connection', (ws) ->
      client = @clientCount++
      @clients.insert(ws, client)
      @send(ws, {type: 'connected'})

      ws.on 'message', (json) ->
        ev = JSON.parse(json)
        console.log "<- ", ev
        @clientEvents.push ev

    @game = new Game
    @game.register(@)
    # @game.before = ->
      # console.log('Tick')

    @game.load (bmpData, tiles) =>
      console.log("@game.load")
      @start()

  requestServerTick: (next) =>
    delta_ms = Date.now() - @last
    if delta_ms >= @frequency
      callback = => next(delta_ms)
      setTimeout callback, 0
    else
      callback = => @requestServerTick(next)
      setTimeout callback, @frequency - delta_ms

  start: =>
    @last = Date.now()
    @game.start(@requestServerTick)

  step: (game, timestamp, delta_s) ->
    @receive(@clientEvents)
    @clients.each (ws, id) =>
      @send(ws, game.state)

  receive: (events) ->
    # for ev in events
      # switch on type? handlers?

  send: (ws, obj) ->
    console.log("->", obj)
    json = JSON.stringify(obj)
    ws.send(obj)

new Server
