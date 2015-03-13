msgpack = require('msgpack5')()
encode  = msgpack.encode
decode  = msgpack.decode

class MessagePackSerializer
  serialize: (obj) ->
    encode(obj)

  deserialize: (raw) ->
    decode(raw)

module.exports = MessagePackSerializer
