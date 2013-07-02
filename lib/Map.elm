module Map (ViewPort, viewPort, mapLayer, tilesInView, tilesInViewBruteforce, renderBuffer, mapTree, tiles, extract) where
import Dict (fromList)
import Json (Object)
import Maybe (Just, Nothing, justs)
import QuadTree (flattenQuadTree, Extent, QuadTree, query, makeExtent, foldM, emptyTree, insertByCoord)

import Native.Map as N

tileWidth = 16 -- in pixels
tileHeight = tileWidth
spriteWidth = 19 -- in tiles
spriteHeight = 10 -- in tiles

mapWidth = 1024 -- In tiles
mapHeight = mapWidth

mapWidthP = mapWidth * tileWidth
mapHeightP = mapHeight * tileHeight


-- A point on the 2D plane
type Coord = (Float, Float)

-- Convenience type for the width & height of the view port,
-- as well as the ship's current (x,y) coordinates
data ViewPort = ViewPort { vw : Float
                         , vh : Float
                         , sx : Float
                         , sy : Float
                         , extent : Extent }

viewPort : (Int, Int) -> Coord -> ViewPort
viewPort (ivw,ivh) (sx,sy) =
  let vw = toFloat ivw
      vh = toFloat ivh
  in ViewPort { vw = vw
           , vh = vh
           , sx = sx
           , sy = sy
           , extent = Extent { north = sy + vh/2
                             , south = sy - vh/2
                             , east = sx + vw/2
                             , west = sx - vw/2
                             }
           }
extract vp =
  let {vw, vh, sx, sy} = vp
   in (vw, vh, sx, sy)

-- Native
renderBuffer : FGroup -> (Int,Int) -> (Int,Int) -> FImage
-- renderBuffer tileForm width height (x,y) = imagycanvas

-- Native
mapSprite : Int -> Int -> (Int, Int) -> Form
-- mapSprite (x,y) = FImage tileWidth tileHeight (x,y) into the lvl map sprite

-- Native
tiles : [Tile]

indexToSpriteCoord : Int -> Coord
indexToSpriteCoord index =
  let index' = index - 1 -- struct index -> spritemap index
      row = index `div` spriteWidth
      col = index `rem` spriteWidth
   in scale (toFloat col, toFloat row) (tileWidth, tileHeight)

-- XXX: Something something matrix?
scale : Coord -> (Int, Int) -> Coord
scale (ax,ay) (sx,sy) = (ax*sx, ay*sy)

-- Project this absolute map coordinate to this viewport
-- y coord is flipped in Elm
-- XXX: Flip everything to NW = 0,+y?
project : ViewPort -> Coord -> Coord
project (ViewPort vp) (x,y) = (x-vp.sx, y-vp.sy)

-- Give the tiles to draw given:
-- view port, tile width, tile height
--tilesInView : ViewPort -> Int -> Int -> ([Int], [Int], [(Int,Int)])
tilesInViewBruteforce (ViewPort vp) w h ratio =
  let {vw,vh,sx,sy} = vp
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

mapExtent = makeExtent mapHeightP 0 mapWidthP 0

-- col, row, index??
-- these will be different
type Tile = (Coord, Int)
mapTree : [Tile] -> QuadTree [Tile]
mapTree ts =
  let tree = foldM (\tree (coord, i) ->
        insertByCoord mapExtent coord (coord, i) tree
          ) emptyTree ts
    in case tree of
      Just tree -> tree
      Nothing -> emptyTree

--tilesInView : ViewPort -> QuadTree Int -> [(Coord, [Tile])]
tilesInView (ViewPort vp) tree =
  query mapExtent tree vp.extent
  --concatMap (\(qcoord, tiles) -> tiles) (flattenQuadTree mapExtent tree)
  --tree

--tileToForm : ViewPort -> Tile -> Form
tileToForm vp (coord, i) =
  let form = N.mapSprite tileWidth tileHeight (indexToSpriteCoord i)
   in form |> move (project vp coord)

dimensions (ViewPort vp) =
  let {vw, vh} = vp
   in (vw, vh)

--mapLayer vp tree =
--  let (vw,vh,sx,sy) = vp
--      tiles = tilesInView vp tree
--      --coordToIndex (col,row) = ((row * mapWidth) + col, col, row)
--      --indicesAndCoords = justs <| map (N.tileForIndex . coordToIndex) (filter (\(c, r) -> c >= 0 && r >= 0) coords)
--      s (x,y) = N.mapSprite tileWidth tileHeight (x,y)
--      relCoord (x,y) = (x-sx, 0-(y-sy))
--      coordToTile (i,c,r) = s (indexToSpriteCoord (i - 1)) |> move (relCoord (toXY (c,r)))
--      tileForms = map coordToTile indicesAndCoords
--  in (indicesAndCoords, N.renderBuffer (group tileForms) vw vh (0,0))

-- TODO: Render map super-tiles of a certain size (except for animated)
--mapLayer : ViewPort -> QuadTree Int -> Form
mapLayer vp tree =
  let tiles = tilesInView vp tree
      tileForms = map (tileToForm vp) tiles
   --in (N.renderBuffer (group tileForms) (dimensions vp) (0,0), tiles)
   in (group tileForms, tiles)
