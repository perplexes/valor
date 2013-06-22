module Subspace where
import Keyboard (arrows)
import Window (dimensions)
import Text as T
import Random
import Json
import Http (Waiting, Failure, Success)

import Loader (getJson)
import Starfield (starLayer, tileLevel1, tileLevel2, viewPort)

-- Constants
mapW = 6400
mapH = 4800
shipW = 170
shipH = 166

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

type GameState = { x : Float, y : Float, angle : Float, dx : Float, dy : Float, t : Float }

defaultGame = { x=100.0, y=100.0, angle=0.0, dx=0.0, dy=0.0, t=0.0 }

-- Calculate new gamestate
-- Old GameState + Input = New GameState
stepGame : Input -> GameState -> GameState
stepGame (Input t (UserInput ui)) gs =
  let {x,y,angle,dx,dy} = gs
  in { gs | dx <- clamp (0-1000) 1000 (dx + toFloat (0-ui.y) * 10 * sin angle)
          , dy <- clamp (0-1000) 1000 (dy + toFloat (0-ui.y) * 10 * cos angle)
          , angle <- angle + t * (0-3) * toFloat ui.x
          , x <- {-clamp (shipW/2) (mapW - shipW/2) <|-} x + t * dx
          , y <- {-clamp (shipH/2) (mapH - shipH/2) <|-} y + t * dy
          , t <- t}


{- Display -}

background w h = filled black (rect w h) |> move (0,0)

ship vw vh angle =
  sprite shipW shipH (0, 0) "/assets/ship2.png" |> rotate angle
                                                |> scale 0.25

scene : (Int, Int) -> [Form] -> GameState -> [(Int,Int)] -> [(Int,Int)] -> Element
scene (w,h) forms gs l2coords l1coords =
  let sceneElement = collage w h forms
  in container w h topLeft <| layers [
    sceneElement
    , flow down [
      --debug "Stars" (left,top,right,bottom,ltr,ttb)
      debug "gameState" gs
      , debug "l2coords" l2coords
      , debug "l1coords" l1coords
      --, debug "map" gameMap
      --,debug "Startile" (starTile (w,h,gameState.x,gameState.y))
    ]
  ]
--scene (w,h) forms gameState = collage w h forms

whiteTextForm string =
  text . T.color white <| toText string

debug key value =
  whiteTextForm <| key ++ ": " ++ (show value)

display : (Int,Int) -> GameState -> Tile -> Tile -> Element
display (w,h) gs tile1 tile2 =
  let vp = viewPort (w,h,gs.x,gs.y)
      (layer2, l2coords) = starLayer vp tile2
      (layer1, l1coords) = starLayer vp tile1
      backgroundLayer = background w h
      shipLayer = ship w h gs.angle
      displayLayers = [backgroundLayer] ++ layer2 ++ layer1 ++ [shipLayer]
  in scene (w,h) displayLayers gs l2coords l1coords

delta = lift inSeconds (fps 30)
--avgFPS = average 10 delta
input = sampleOn delta (lift2 Input delta userInput)

gameState : Signal GameState
gameState = foldp stepGame defaultGame input

main = lift4 display dimensions gameState tileLevel1 tileLevel2
