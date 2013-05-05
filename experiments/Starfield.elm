{- XXX: Not used yet -}

module Starfield where
import Random

starTilesize = 1024
starDensity = 31
randstar _ = rangeSync 0 starTilesize
starPoints = map (\x -> (randstar x, randstar x)) [0..starDensity]
starsLevel1 = starPoints -- closer
starsLevel2 = starPoints -- farther
l1color = rgb 184 184 184
l2color = rgb 96 96 96

starLayers (iVw,iVh) =
  let
      vw = toFloat iVw
      vh = toFloat iVh
      left = floor <| (0 - vw) / (toFloat starTilesize)
      top = floor <| (0 - vh) / (toFloat starTilesize)
      right = floor <| vw / (toFloat starTilesize)
      bottom = floor <| vh / (toFloat starTilesize)
      ltr = [left..right]
      ttb = [top..bottom]
      st (c,r) = starTile (c,r) (vw,vh)
  in (left,top,right,bottom,ltr,ttb,
    foldl (\r a ->
       foldl (\c a2 ->
         a2 ++ st (c,r)
       ) a ltr
     ) [] ttb)

starTile (c,r) (vw,vh) =
  let dx1 x = (c * starTilesize + x - vw) / 2
      dy1 y = (r * starTilesize + y - vh) / 2
      dx2 x = (c * starTilesize + x) / 3 + vw/2
      dy2 y = (r * starTilesize + y) / 3 + vh/2
      shape = rect 1 1
      filledRect color = filled color shape
      moved color (x,y) = move x y (filledRect color)
      star color (x,y) = moved color (x,y)
  in map (\(x,y) -> star l1color (dx1 x, dy1 y)) starsLevel1 ++
     map (\(x,y) -> star l2color (dx2 x, dy2 y)) starsLevel2
