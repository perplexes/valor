{- XXX: Not used yet -}

module Starfield where
import Random

starTilesize = 1024
starDensity = 31
randstar _ = rangeSync 0 starTilesize
--starPoints = map (\x -> (randstar x, randstar x)) [0..starDensity]
--starsLevel1 = starPoints -- closer
--starsLevel2 = starPoints -- farther
l1color = rgb 184 184 184
l2color = rgb 96 96 96

-- Convenience type for the width & height of the view port,
-- as well as the ship's current (x,y) coordinates
type ViewPort = (Float,Float,Float,Float)
viewPort (vw,vh,sx,sy) = (toFloat vw, toFloat vh, sx, sy)

randomList : Int -> Signal [Int]
randomList _ = combine (map (Random.range 0 starTilesize . constant) [0..starDensity])

-- A single random star tile
randomTile : Int -> Signal [(Int,Int)]
randomTile _ = lift2 zip (randomList 1) (randomList 2)

-- [stars level 1 (closer), level 2 (farther)]
starTiles : Signal [[(Int,Int)]]
starTiles = combine [randomTile 1, randomTile 2]

-- Draw star tiles to the viewport. + debug info
-- My kingdom for an array comprehension.
starLayers : ViewPort -> [[(Int,Int)]] -> (Int,Int,Int,Int,[Int],[Int],[Form])
starLayers vp starTiles =
  -- We pad by half a viewport width/height on each side
  let (vw,vh,sx,sy) = vp
      starTilesize' = toFloat starTilesize
      left = floor <| (sx - vw) / starTilesize'
      top = floor <| (sy - vh) / starTilesize'
      right = floor <| (sx + vw) / starTilesize'
      bottom = floor <| (sy + vh) / starTilesize'
      ltr = [left..right]
      ttb = [top..bottom]
      st = starTile vp starTiles
  in (left,top,right,bottom,ltr,ttb,
    foldl (\r a ->
       foldl (\c a2 ->
         a2 ++ st (c,r)
       ) a ltr
     ) [] ttb)

-- Draw a particular tile, which is actually two star tiles:
-- Level 1 stars are closer and a bit brighter, and move at /2 speed.
-- Level 2 stars are further, a bit darker, and move even slower.
starTile : ViewPort -> [[(Int,Int)]] -> (Int, Int) -> [Form]
starTile (vw,vh,sx,sy) starTiles (c,r)  =
  let starsLevel1 = head starTiles
      starsLevel2 = last starTiles
      absX x = c * starTilesize + x
      absY y = r * starTilesize + y
      dx1 x = ((absX x) - sx) / 2
      dy1 y = ((absY y) - sy) / 2
      dx2 x = ((absX x) - sx) / 3
      dy2 y = ((absY y) - sy) / 3
      shape = rect 1 1
      filledRect color = filled color shape
      moved color (x,y) = move x y (filledRect color)
      star color (x,y) = moved color (x,y)
  in map (\(x,y) -> star l1color (dx1 x, (0-dy1 y))) starsLevel1 ++
     map (\(x,y) -> star l2color (dx2 x, (0-dy2 y))) starsLevel2

--main = lift asText <| lift (starLayers (viewPort (0,0,0,0))) starTiles
