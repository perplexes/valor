class EffectView extends View
  View.extended(@, "Effects")

  constructor: (entity) ->
    entity.movie.onComplete = => entity.expire()
    # Todo, add entity to game tree
    super(entity, entity.movie)
