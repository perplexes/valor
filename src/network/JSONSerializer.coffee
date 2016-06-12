class JSONSerializer
  # dump/generate/serialize/freeze/encode
  serialize: (obj) ->
    JSON.stringify(obj)

  deserialize: (raw) ->
    JSON.parse(raw)

module.exports = JSONSerializer
