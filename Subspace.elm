module Subspace where
import Keyboard
import Window
import Graphics.Text as T
--import Starfield
import Random

-- Constants
mapW = 6400
mapH = 4800
shipW = 170
shipH = 166

starTilesize = 1024
starDensity = 31
randstar _ = rangeSync 0 starTilesize
starPoints = map (\x -> (randstar x, randstar x)) [0..starDensity]
starsLevel1 = starPoints -- closer
starsLevel2 = starPoints -- farther
l1color = rgb 184 184 184
l2color = rgb 96 96 96

-- Convenience type for the width & height of the view port,
-- as well as the ship's current (x,y) coordinates
type ViewPort = (Float,Float,Float,Float)
viewPort (vw,vh,sx,sy) = (toFloat vw, toFloat vh, sx, sy)

-- Draw star tiles to the viewport. + debug info
-- My kingdom for an array comprehension.
starLayers : ViewPort -> (Int,Int,Int,Int,[Int],[Int],[Form])
starLayers vp =
  -- We pad by half a viewport width/height on each side
  let (vw,vh,sx,sy) = vp
      starTilesize' = toFloat starTilesize
      left = floor <| (sx - vw) / starTilesize'
      top = floor <| (sy - vh) / starTilesize'
      right = floor <| (sx + vw) / starTilesize'
      bottom = floor <| (sy + vh) / starTilesize'
      ltr = [left..right]
      ttb = [top..bottom]
      st = starTile vp
  in (left,top,right,bottom,ltr,ttb,
    foldl (\r a ->
       foldl (\c a2 ->
         a2 ++ st (c,r)
       ) a ltr
     ) [] ttb)

-- Draw a particular tile, which is actually two star tiles:
-- Level 1 stars are closer and a bit brighter, and move at /2 speed.
-- Level 2 stars are further, a bit darker, and move even slower.
starTile : ViewPort -> (Int, Int) -> [Form]
starTile (vw,vh,sx,sy) (c,r)  =
  let absX x = c * starTilesize + x
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

-- Override standard clamp to take floats
clamp min max x =
  if | x < min -> min
     | x < max -> x
     | otherwise -> max

-- Input is currently Keyboard.arrows
data UserInput = UserInput { x : Int, y : Int }

userInput =
  lift UserInput arrows

data Input = Input Float UserInput

data GameState = GameState { x : Float, y : Float, angle : Float, dx : Float, dy : Float, t : Float }

defaultGame = GameState { x=100.0, y=100.0, angle=0.0, dx=0.0, dy=0.0, t=0.0 }

-- Calculate new gamestate
-- Old GameState + Input = New GameState
stepGame (Input t (UserInput ui)) (GameState gs) =
  let {x,y,angle,dx,dy} = gs in
  GameState { gs | dx <- clamp (0-1000) 1000 (dx + toFloat ui.y * 10 * sin angle)
                 , dy <- clamp (0-1000) 1000 (dy + toFloat ui.y * 10 * cos angle * (0-1))
                 , angle <- angle + t * 3 * toFloat ui.x
                 , x <- {-clamp (shipW/2) (mapW - shipW/2) <|-} x + t * dx
                 , y <- {-clamp (shipH/2) (mapH - shipH/2) <|-} y + t * dy
                 , t <- t}


{- Display -}

background w h = filled black (rect w h) |> move 0 0 -- w/2 h/2

ship vw vh angle =
  sprite shipW shipH (0, 0) "ship2.png" |> rotate angle
                                        |> scale 0.25

whiteTextForm string =
  text . T.color white <| toText string

debug key value =
  whiteTextForm <| key ++ ": " ++ (show value)

display : (Int,Int) -> GameState -> Element
display (w,h) (GameState gameState) =
  let vp = viewPort (w,h,gameState.x,gameState.y)
      (left,top,right,bottom,ltr,ttb,sl) = starLayers vp
      displayLayers = [ background w h] ++ sl ++ [ ship w h gameState.angle ]
  in container w h topLeft <| layers [
    collage w h displayLayers
    , flow down [
      debug "Stars" (left,top,right,bottom,ltr,ttb)
      ,debug "gameState" gameState
      --,debug "Startile" (starTile (w,h,gameState.x,gameState.y))
    ]
  ]

delta = lift inSeconds (fps 30)
--avgFPS = average 10 delta
input = sampleOn delta (lift2 Input delta userInput)

gameState = foldp stepGame defaultGame input

main = lift2 display dimensions gameState
