class EffectView extends View
  View.extended(@, "Effects")
  # Some effects to preload
  @load("explode0", "assets/shared/graphics/explode0.png", 112, 16, 1, 7)
  @load("explode1", "assets/shared/graphics/explode1.png", 288, 288, 6, 6)

  constructor: (entity) ->
    entity.movie.onComplete = => entity.expire()
    # Todo, add entity to game tree
    super(entity, entity.movie)
