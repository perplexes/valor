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
      clientId = @clientCount++
      wst = new WebSocketTransport(ws)
      network = wst.network
      network.connected = true
      @clients.insert(network, clientId)

      console.log("[WSST] Connected:", clientId, ws.upgradeReq.connection.remoteAddress)

      network.on "close", (data) =>
        console.log("[WSST] Close")
        @clients.remove(clientId)

      @onConnectionCallback(network)

  step: (game, timestamp, delta_s) ->
    @clients.each (client) ->
      if client.connected
        client.dispatch("receive", client)
        client.receiveBuffer.reset()

    @clients.each (client) ->
      if client.connected
        client.dispatch("step", client)
        # Don't use client#step
        # it won't align perfectly with server tick
        client.flush()

  onConnection: (callback) ->
    @onConnectionCallback = callback

module.exports = WebSocketServerTransport
