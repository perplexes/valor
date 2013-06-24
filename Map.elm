module Map (viewPort, mapLayer, tilesInView) where
import Dict (fromList)
import Json (Object)
import Maybe (Just, Nothing, justs)

import Native.Map as N

tileWidth = 16
tileHeight = tileWidth
spriteWidth = 19
spriteHeight = 10

mapWidth = 1024 -- In tiles
mapHeight = mapWidth

--mapDict = fromList [(512,0)]
tileForIndex : (Int, Int, Int) -> Maybe (Int, Int, Int)
--tileForIndex (idx, col, row) = if | idx `mod` 10 == 0 -> Just (0, col, row)
--                                  | otherwise -> Nothing

-- 1: 0,0, 2: 0,16
indexToSpriteCoord index =
  let row = index `div` spriteWidth
      col = index `rem` spriteWidth
   in toXY (col, row)

toXY (col,row) = (col * tileWidth, row * tileHeight)

-- Convenience type for the width & height of the view port,
-- as well as the ship's current (x,y) coordinates
type ViewPort = (Float,Float,Float,Float)
viewPort (vw,vh) (sx,sy) = (toFloat vw, toFloat vh, sx, sy)

-- Give the tiles to draw given:
-- view port, tile width, tile height
--tilesInView : ViewPort -> Int -> Int -> ([Int], [Int], [(Int,Int)])
tilesInView vp w h ratio =
  let (vw,vh,sx,sy) = vp
      tileHeight = toFloat w
      tileWidth = toFloat h
      l = floor <| ((sx/ratio) - (vw/2)) / tileWidth
      t = floor <| ((sy/ratio) - (vh/2)) / tileHeight
      r = ceiling <| ((sx/ratio) + (vw/2)) / tileWidth
      b = ceiling <| ((sy/ratio) + (vh/2)) / tileHeight
      ltr = [l..r]
      ttb = [t..b]
  in foldl (\r a ->
       foldl (\c a2 ->
         (c, r) :: a2
       ) a ltr
     ) [] ttb

mapLayer vp =
  let (vw,vh,sx,sy) = vp
      coords = tilesInView vp tileWidth tileHeight 1
      coordToIndex (col,row) = ((row * mapWidth) + col, col, row)
      indicesAndCoords = justs <| map (N.tileForIndex . coordToIndex) (filter (\(c, r) -> c >= 0 && r >= 0) coords)
      s (x,y) = sprite tileWidth tileHeight (x,y) "/arenas/trench_9/tileset.png"
      relCoord (x,y) = (x-sx, 0-(y-sy))
  in (indicesAndCoords, group <| map (\(i,c,r) ->
      s (indexToSpriteCoord (i - 1)) |> move (relCoord (toXY (c,r)))
         ) indicesAndCoords)

--c,r to index, index to spriteindex (maybe), spriteindex to x,y in spritemap, to sprite obj
--c,r to move x,y coordinates
--Gah, I need to filter out things that won't appear, but I still need..
--justs might be the thing I want, but there's no