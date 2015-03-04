class AI
  constructor: (game, follow) ->
    @follow = follow
    @ship = new Ship(game.simulator, false, {ship: 1, pos: @follow.pos.clone().addXX(32)})

  step: (game, timestamp, ms) ->
    # Have the other ship follow player
    r = Math.sqrt(Math.pow(@follow.pos.x - @ship.pos.x, 2) + Math.pow(@follow.pos.y - @ship.pos.y, 2))
    r -= @follow.w*2
    angle = Math.atan2(@follow.pos.y - @ship.pos.y, @follow.pos.x - @ship.pos.x) + (Math.PI/2)
    @ship.rawAngle = angle/(2*Math.PI)
    @ship.vel.clear().addPolar(r, angle)

module.exports = AI