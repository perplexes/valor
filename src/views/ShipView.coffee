class ShipView extends View
  View.extended(@, "Other ships")

  constructor: (entity) ->
    # TODO: This might need an object of options (it has a 2px offset, since the ships are 32px)
    movie = Asset.movie("ship#{entity.options.ship}", 0, false, false)
    super(entity, movie)

  update: (viewport) ->
    if @entity.player
      @displayObject.position.x = viewport.hw
      @displayObject.position.y = viewport.hh
    else
      super(viewport)

    texture = Math.round((@entity.angle * @displayObject.textures.length) / (2 * Math.PI))
    i = Math.mod(texture, @displayObject.textures.length)
    @displayObject.gotoAndStop(i)

  layerFor: (scene, entity) ->
    if entity.player
      "Selfship"
    else
      "Other ships"
