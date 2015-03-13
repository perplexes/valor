WebSocketServer = require("ws").Server
WebSocketTransport = require("./WebSocketTransport")
Network = require("../Network")
DLinkedList = require("../models/DLinkedList")

class WebSocketServerTransport
  wss: null
  clients: new DLinkedList
  clientCount: 0

  constructor: (options) ->
    @wss = new WebSocketServer(port: 8080)
    @wss.on "connection", (ws) =>
      client = @clientCount++
      wst = new WebSocketTransport(ws)
      network = wst.network
      network.connected = true
      @clients.insert(network, client)

      console.log("[WSST] Connected:", client, ws.upgradeReq.connection.remoteAddress)

      network.on "close", (data) =>
        @clients.remove(client)

      @onConnectionCallback(network)

  step: (game, timestamp, delta_s) ->
    @clients.each (client) ->
      client.dispatch("receive", client)
      client.receiveBuffer.reset()

    @clients.each (client) ->
      client.dispatch("step", client)
      # Don't use client#step
      # it won't align perfectly with server tick
      client.flush()

  onConnection: (callback) ->
    @onConnectionCallback = callback

module.exports = WebSocketServerTransport
