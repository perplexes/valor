class WebSocketTransport
  network: null
  ws: null

  # url = "ws://host:8080"
  # new WebSocket(url)
  constructor: (ws) ->
    @network = Network.new(@)
    @ws = ws

    @ws.on "open", (data) =>
      @network.dispatch("open", data)

    @ws.on "message", (data) =>
      @network.dispatch("message", data)

    @ws.on "close", (data) =>
      @network.dispatch("close", data)

  send: (message) ->
    @ws.send(message)

  @default: (url) ->
    new WebSocketTransport(
      new WebSocket(url)
    )
