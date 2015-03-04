View = require './View'
Asset = require './Asset'

class BulletView extends View
  View.extended(@, "Projectiles")

  constructor: (bullet) ->
    row = bullet.level
    row += 5 if bullet.bouncing
    asset = Asset.assets["bullets"]
    movie = Asset.movie("bullets", 0.5, true, true, asset.row(row))
    super(bullet, movie)

module.exports = BulletView