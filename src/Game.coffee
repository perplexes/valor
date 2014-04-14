`
Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};
`

class Game
  observers: []

  constructor: ->
    @simulator = new Simulator
    @register(@simulator)

    # This should happen when the server starts a replication to us
    # or it's single player mode.
    @othership = new Ship(@simulator, false, {ship: 1})
    @ship = new Ship(@simulator, true, {ship: 0, keys: @keys})

  load: (callback) ->
    Map.load (bmpData, tiles) =>
      callback(bmpData, tiles)
      for tile in tiles
        @simulator.insertStatic(tile)

  register: (observer) ->
    @observers.push(observer)

  step: (timestamp, callback) ->
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

    callback.apply(@, @step)
