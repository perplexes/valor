module Map (starTiles, starLayers, viewPort) where
import Json (Object)
import Starfield (ViewPort, tiles)

tileWidth = 1024 * 16
tileHeight = tileWidth

drawMap : Object -> ViewPort -> ([Int], [Int], [Form])
drawMap map vp =
  let (ltr, ttb) = tiles vp tileWidth tileHeight
      dt = drawTile vp map
  in (ltr,ttb,
    foldl (\r a ->
       foldl (\c a2 ->
         a2 :: dt (c,r)
       ) a ltr
     ) [] ttb)

drawTile : ViewPort -> Object -> (Int, Int) -> Form
drawTile (vw,vh,sx,sy) map (c,r) =
  let abs = (tileWidth * r) + c
      tile = map