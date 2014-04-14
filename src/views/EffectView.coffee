class EffectView extends View
  constructor: (entity) ->
    entity.movie.onComplete = => entity.expire()
    # Todo, add entity to game tree
    super(entity, entity.movie)
