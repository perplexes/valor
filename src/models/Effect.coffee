Entity = require("./Entity")

# This one is a little weird, it's an entity and view since it can move.
# TODO: Are effects always animated?
# TODO: Effect on server side?
class Effect extends Entity
  Entity.extended(@)

  movie: null
  constructor: (pos, vel, width, height, movie) ->
    @movie = movie
    super(
      Simulator.simulator,
      pos,
      vel,
      width,
      height
    )

  @create: (name, pos, vel) ->
    return unless Asset?
    movie = Asset.movie(name, 0.5, false, true)
    new @(pos, vel, movie.width, movie.height, movie)

  # No op
  collide: ->

module.exports = Entity