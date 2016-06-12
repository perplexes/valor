Simulator = require("./models/Simulator")
Ship = require("./models/Ship")
Map = require("./models/Map")


`
Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};
`

class Game
  observers: []

  constructor: ->
    @simulator = new Simulator

  # bulk insert for Rbush
  load: (callback) ->
    Map.load (bmpData, tiles) =>
      callback(bmpData, tiles)
      @simulator.insertStatic(tiles)

  register: (observer) ->
    @observers.push(observer)

  # All the state that this entity is interested in observing
  # TODO: This is probably the size of their minimap
  # - minus ships that are hidden from them (cloak)
  # TODO: how big should this be?
  # everyone should probably have the same viewport size
  # i.e. no observe advantage from huge screen?
  # ah, minimap size, yes (your quadrent)
  state: (entity) ->
    entities = []
    @simulator.dynamicTree.searchExpand(entity._extent, 1280, 800, (nearEntity) ->
      entities.push(nearEntity.serialize())
    , @)
    entities

  start: (callback) ->
    console.log("game.start")
    # Put simulate step at the end?
    @register(@simulator)
    @callback = callback
    @step(0)

  step: (timestamp) =>
    @before() if @before?

    @last ||= 0
    delta = timestamp - @last
    # We stopped the game, just assume a frame
    delta = 16 if delta > 1000
    @last = timestamp
    delta_s = delta / 1000

    # Fire step callbacks
    # (Like rendering to screen, sending server data, etc)
    for observer in @observers
      observer.step(@, timestamp, delta_s)

    @after() if @after?

    if window?
      @callback.call(window, @step)
    else
      @callback(@step)

module.exports = Game
