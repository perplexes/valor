module Subspace where
import Keyboard
import Window
import Graphics.Text as T
--import Starfield

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

-- Override standard clamp to take floats
clamp min max x =
  if | x < min -> min
     | x < max -> x
     | otherwise -> max

--log message = castStringToJSString message
--foreign export jsevent "elm_log"
--  log :: Signal JSString

mapW = 6400
mapH = 4800
shipW = 170
shipH = 166

data UserInput = UserInput { x : Int, y : Int }

userInput =
  lift UserInput arrows

data Input = Input Float UserInput

data GameState = GameState { x : Float, y : Float, angle : Float, dx : Float, dy : Float, t : Float }

defaultGame = GameState { x=100.0, y=100.0, angle=0.0, dx=0.0, dy=0.0, t=0.0 }

stepGame (Input t (UserInput ui)) (GameState gs) =
  let {x,y,angle,dx,dy} = gs in
  GameState { gs | dx <- clamp (0-100) 100 (dx + toFloat ui.y * 2 * sin angle)
                 , dy <- clamp (0-100) 100 (dy + toFloat ui.y * 2 * cos angle * (0-1))
                 , angle <- angle + t * 3 * toFloat ui.x
                 , x <- clamp (shipW/2) (mapW - shipW/2) <| x + t * dx
                 , y <- clamp (shipH/2) (mapH - shipH/2) <| y + t * dy
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

display (w,h) (GameState gameState) =
  let (left,top,right,bottom,ltr,ttb,sl) = starLayers (w,h)
      displayLayers = [ background w h ] ++ sl ++ [ ship w h gameState.angle ]
      --displayLayers = [ ship w h gameState.angle ]
  in container w h topLeft <| layers [
    collage w h displayLayers
    , flow down [
      debug "Stars" (left,top,right,bottom,ltr,ttb),
      debug "gameState" gameState
    ]
  ]
  --in asText <| show (displayLayers)

delta = lift inSeconds (fps 30)
avgFPS = average 10 delta
input = sampleOn delta (lift2 Input delta userInput)

gameState = foldp stepGame defaultGame input

--main = lift2 display dimensions gameState
main = lift2 display (constant (640, 480)) gameState

--display (w,h) =
  --asText <| show (w,h)
  --container w h topLeft (collage w h [background w h])
--main = lift display dimensions
