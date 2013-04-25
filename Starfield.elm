module Starfield where
starTilesize = 1024
starDensity = 31
randstar _ = JavaScript.randInRange 0 starTilesize
starPoints = map (\x -> (randstar x, randstar x)) [0..starDensity]
starsLevel1 = starPoints -- closer
starsLevel2 = starPoints -- farther
l1color = rgb 184 184 184
l2color = rgb 96 96 96

starLayers (vx,vy,vw,vh) =
  let left = floor $ (vx - vw) / (toFloat starTilesize)
      top = floor $ (vy - vh) / (toFloat starTilesize)
      right = floor $ (vx + vw) / (toFloat starTilesize)
      bottom = floor $ (vy + vh) / (toFloat starTilesize)
      ltr = [left..right]
      ttb = [top..bottom]
      st (c,r) = starTile (c,r) (vx,vy,vw,vh)
  in (left,top,right,bottom,ltr,ttb,
    foldl (\r a ->
       foldl (\c a2 ->
         a2 ++ st (c,r)
       ) a ltr
     ) [] ttb)

starTile (c,r) (vx,vy,vw,vh) =
  let dx1 x = (c * starTilesize + x - vx + vw) / 2
      dy1 y = (r * starTilesize + y - vy + vh) / 2
      dx2 x = (c * starTilesize + x - vx) / 3 + vw/2
      dy2 y = (r * starTilesize + y - vy) / 3 + vh/2
      star color (x, y) = filled color (rect 1 1 (x,y))
  in map (\(x,y) -> star l1color (dx1 x, dy1 y)) starsLevel1 ++
     map (\(x,y) -> star l2color (dx2 x, dy2 y)) starsLevel2
