module Subspace where
import Keyboard (arrows)
import Window (dimensions)
import Text as T
import Random
import Json
import Http (Waiting, Failure, Success)

import Loader (getJson)
import Starfield (starLayer, tileLevel1, tileLevel2)
import Map (mapLayer, viewPort, tiles)

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

defaultGame = { x=0.0, y=0.0, angle=0.0, dx=0.0, dy=0.0, t=0.0 }
--defaultGame = { x=0.0, y=0.0, angle=0.0, dx=0.0, dy=0.0, t=0.0 }

-- Calculate new gamestate
-- Old GameState + Input = New GameState
stepGame : Input -> GameState -> GameState
stepGame (Input t (UserInput ui)) gs =
  let {x,y,angle,dx,dy} = gs
  in { gs | dx <- clamp (0-1000) 1000 (dx + toFloat (0-ui.y) * 10 * sin angle)
          , dy <- clamp (0-1000) 1000 (dy + toFloat ui.y * 10 * cos angle)
          , angle <- angle + t * (0-3) * toFloat ui.x
          , x <- {-clamp (shipW/2) (mapW - shipW/2) <|-} x + t * dx
          , y <- {-clamp (shipH/2) (mapH - shipH/2) <|-} y + t * dy
          , t <- t}


{- Display -}

ship angle =
  sprite shipW shipH (0, 0) "/assets/ship2.png" |> rotate angle
                                                |> scale 0.25

--scene : (Int, Int) -> GameState -> Form -> [Form] ->  Element
scene (w,h) gs debugging forms =
  let sceneElement = collage w h forms
      window = (w,h)
   --in sceneElement
  in container w h topLeft <| layers [
    sceneElement
    , flow down [
    ----  --debug "Stars" (left,top,right,bottom,ltr,ttb)
      debug "db" debugging,
      debug "gameState" gs
      --debug "maplayer" mapl
    --  , debug "l2coords" l2debug
    --  , debug "l1coords" l1debug
    --  --, debug "map" gameMap
    --  --,debug "Startile" (starTile (w,h,gameState.x,gameState.y))
    ]
  ]
--scene (w,h) forms gameState = collage w h forms

whiteTextForm string =
  text . T.color white <| toText string

debug key value =
  whiteTextForm <| key ++ ": " ++ (show value)

--display : (Int,Int) -> GameState -> Tile -> Tile -> Element
display window gs tile1 tile2 (allTiles, mapTree) =
  let vp = viewPort window (gs.x,gs.y)
      (mapl, tiles) = mapLayer vp mapTree
      sl2 = starLayer vp tile2
      sl1 = starLayer vp tile1
  in scene window gs (length tiles) [
    sl2,
    sl1,
    mapl,
    ship gs.angle
  ]

delta = lift inSeconds (fps 60)
--avgFPS = average 10 delta
input = sampleOn delta (lift2 Input delta userInput)

gameState : Signal GameState
gameState = foldp stepGame defaultGame input

main = lift5 display dimensions gameState tileLevel1 tileLevel2 (constant (Map.tiles, (Map.mapTree Map.tiles)))
