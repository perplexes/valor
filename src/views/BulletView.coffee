class BulletView extends View
  View.extended(@, "Projectiles")

  constructor: (bullet) ->
    row = bullet.level
    row += 5 if bullet.bouncing
    movie = Asset.movie("bullets", 0.5, true, true, asset.textures[row])
    super(bullet, movie)