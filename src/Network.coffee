DLinkedList = require("./models/DLinkedList")
JSONSerializer = require("./network/JSONSerializer")
MessagePackSerializer = require("./network/MessagePackSerializer")

class Network
  connected: false
  sendBuffer: new DLinkedList
  sendDirty: false
  receiveBuffer: new DLinkedList
  receiveDirty: false
  connected: false
  eventHandlers: {}
  lastFlush: 0
  meta: {}

  # TODO: Where should we encode hosts/ports/etc?
  # new WST("ws://#{host}:8080"
  constructor: (transport) ->
    @transport = transport
    @serializer = new MessagePackSerializer

    @on "open", =>
      @connected = true

    @on "close", =>
      @connected = false

    @on "message", (raw) =>
      batch = @serializer.deserialize(raw)
      # console.log("[Network] <- ", batch)
      # TODO:
      # This may not be optimal
      # if all the receive functions take batches themselves
      # we can just call them over and over instead of splitting
      for message in batch
        @receiveEvent(message)

  receiveEvent: (message) ->
    # TODO: Have callers tell us which messages to buffer
    if message.type == "gamestate" || message.type == "keys"
      @receiveDirty = true
      @receiveBuffer.insert(message, message.timestamp)
    # connected/join/part/etc messages are synchronous
    else
      @dispatch(message.type, message)

  receive: (callback) ->
    return null unless @receiveDirty

    @receiveBuffer.each (ev) ->
      callback(ev)

    @receiveBuffer.reset()
    @receiveDirty = false

  on: (event, callback) ->
    unless @eventHandlers[event]?
      @eventHandlers[event] = new DLinkedList

    @eventHandlers[event].insert(callback, callback)

  dispatch: (event, data) ->
    return unless @eventHandlers[event]?

    @eventHandlers[event].each (handler) ->
      # console.log("[Network] Dispatch: ", event)
      handler(data)

  enqueue: (data) ->
    # TODO: Does it matter if this is different than server time?
    unless data.timestamp?
      data.timestamp = Date.now() | 0

    @sendBuffer.insert(data, data.timestamp)
    @sendDirty = true

  # TODO: Compression, different ser. format, etc
  flush: ->
    return null unless @connected
    return null unless @sendDirty

    obj = @sendBuffer.all()
    # console.log("[Network] -> ", message)

    raw = @serializer.serialize(obj)
    @transport.send(raw)
    @sendBuffer.reset()
    @sendDirty = false

  # TODO: This could be a setInterval, too
  step: (game, timestamp, delta_s) ->
    # console.log("[Network] #step: ", timestamp, @lastFlush, timestamp - @lastFlush)
    if (timestamp - @lastFlush) < 32
      return null
    @flush()
    @lastFlush = timestamp

module.exports = Network
