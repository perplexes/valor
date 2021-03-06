Entity = require("./Entity")
Vector2d = require("./Vector2d")
Effect = require("./Effect")

class Bullet extends Entity
  bounciness: 1
  friction: 0
  damage: 200
  speed: 100
  w: 5
  h: 5

  constructor: (ship, simulator, level, bouncing) ->
    @ship = ship
    @simulator = simulator
    @level = level
    @bouncing = bouncing

    @lifetime = 10 # seconds

    super(
      simulator,
      new Vector2d(0,0).add(ship.pos).addPolar(ship.hw, ship.angle),
      new Vector2d(0,0).add(ship.vel).addPolar(@speed, ship.angle),
      @w, @h
    )

  collide: (object) ->
    if object.constructor.name == "Tile"
      if object.index == 170
        return
      else if @bouncing
        super(object)

    if object.constructor.name == "Ship" && object != @ship
      object.onDamage(@, @damage)
      @expireNow()

  onExpire: ->
    Effect.create('explode0', @pos, null)

  simulate: (delta_s) ->
    @expire() if @ship.safe
    super(delta_s)

module.exports = Bullet
