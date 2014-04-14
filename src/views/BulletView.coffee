class BulletView extends View
  View.extended(@, "Projectiles")

  asset = Asset.load("bullets", 20, 50, 10, 4, "assets/shared/graphics/bullets.png")
  constructor: (bullet) ->
    row = bullet.level
    row += 5 if bullet.bouncing
    movie = Asset.movie("bullets", 0.5, true, true, asset.textures[row])
    super(bullet, movie)