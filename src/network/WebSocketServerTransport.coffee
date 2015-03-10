WebSocketServer = require('ws').Server

class WebSocketServerTransport
  wss: null
  clients: new DLinkedList
  clientCount: 0

  constructor: (options) ->
    @wss = new WebSocketServer(port: 8080)
    @wss.on "connection", (ws) =>
      client = @clientCount++
      network = new Network(ws)
      @clients.insert(network, client)

      console.log("Connected:", client, ws)

      ws.on "message", (data) =>
        network.dispatch("message", data)

      ws.on "close", (data) =>
        network.dispatch("close", data)
        @clients.remove(client)

  step: (game, timestamp, delta_s) ->
    @clients.each (client) ->
      client.dispatch("receive", client)
      client.receiveBuffer.reset()

    @clients.each (client) ->
      client.dispatch("step", client)
      client.flush()
