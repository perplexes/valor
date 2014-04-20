class Server
  constructor: ->
    WebSocketServer = require('ws').Server
    @wss = new WebSocketServer({port: 8080});
    @wss.on 'connection', (ws) ->
      ws.on 'message', (message) ->
        console.log('received: %s', message)
        # ws.send(message)

new Server
