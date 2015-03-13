Network = require("../Network")

class WebSocketTransport
  network: null
  ws: null

  # url = "ws://host:8080"
  # new WebSocket(url)
  constructor: (ws) ->
    @network = new Network(@)
    @ws = ws

    # Client side WebSocket
    if typeof(ws.onopen) == "object"
      if @network.serializer.constructor.name == "MessagePackSerializer"
        ws.binaryType = "arraybuffer"

      ws.onopen = (data) =>
        @network.dispatch("open", data)

      ws.onmessage = (messageEvent) =>
        if @network.serializer.constructor.name == "MessagePackSerializer"
          @network.dispatch("message", new Uint8Array(messageEvent.data))
        else
          @network.dispatch("message", messageEvent.data)

      ws.onclose = (data) =>
        @network.dispatch("close", data)
    # Server side WebSocket
    else
      @network.connected = true

      ws.on "message", (data) =>
        @network.dispatch("message", data)

      ws.on "close", (data) =>
        @network.dispatch("close", data)


  send: (message) ->
    if @ws.readyState == 1
      @ws.send(message)
    else
      @network.dispatch("close")
      @ws.close()

  @default: (url) ->
    wst = new WebSocketTransport(
      new WebSocket(url)
    )

    wst.network

module.exports = WebSocketTransport
