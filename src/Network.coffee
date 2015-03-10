class Network
  connected: false
  sendBuffer: new DLinkedList
  receiveBuffer: new DLinkedList
  # Pending ack from server?
  pendingEvents: new DLinkedList
  connected: false
  eventHandlers: []
  lastFlush: 0
  meta: {}

  # TODO: Where should we encode hosts/ports/etc?
  # WST.new("ws://#{host}:8080"
  constructor: (transport) ->
    @transport = transport

    @on "open", =>
      @connected = true

    @on "close", =>
      @connected = false

    @on "message", (message) =>
      batch = JSON.parse(message.data)
      for event in batch
        @receiveEvent(ev)

  receiveEvent: (event) ->
    if ev.type == "gamestate" || ev.type == "keys"
      receiveBuffer.insert(ev, ev.timestamp)
    # connected/join/part/etc messages are synchronous
    else
      dispatch(ev.type, ev)

  on: (event, function) ->
    if typeof(eventHandlers[event]) === "undefined"
      eventHandlers[event] = new DLinkedList
    
    eventHandlers[event].insert(function, null)

  dispatch: (event, data) ->
    return unless eventHandlers[event]?

    eventHandlers[event].each (handler) ->
      handler(data)

  enqueue: (data) ->
    # TODO: Does it matter if this is different than server time?
    unless data.timestamp?
      data.timestamp = Date.now() | 0

    sendBuffer.insert(data, data.timestamp)
    # TODO: Should this be in here?
    # Maybe should be in client...
    if data.type == "keys"
      pendingEvents.insert(data, data.timestamp)

  # TODO: Compression, different ser. format, etc
  flush: ->
    json = JSON.stringify(sendBuffer.all())
    @transport.send(json)
    sendBuffer.reset()

  step: (game, timestamp, delta_s) ->
    if timestamp - lastFlush > 32 #ms
      flush()
