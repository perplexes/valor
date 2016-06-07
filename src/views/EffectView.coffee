View = require './View'

# TODO: Maybe move asset reference to here from Effect
class EffectView extends View
  View.extended(@, "Effects")

  constructor: (entity) ->
    entity.movie.onComplete = -> entity.expire()
    # Todo, add entity to game tree
    super(entity, entity.movie)

module.exports = EffectView
