class AI
  step: (game, timestamp, ms) ->
    # Have the other ship follow player
    r = Math.sqrt(Math.pow(game.ship.pos.x - game.othership.pos.x, 2) + Math.pow(game.ship.pos.y - game.othership.pos.y, 2))
    r -= game.ship.w*2
    angle = Math.atan2(game.ship.pos.y - game.othership.pos.y, game.ship.pos.x - game.othership.pos.x) + (Math.PI/2)
    game.othership.rawAngle = angle/(2*Math.PI)
    game.othership.vel.clear().addPolar(r, angle)