module Subspace where
import Keyboard
import Window
import Text as T
import Starfield
import Random

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

background w h = filled black (rect w h) |> move 0 0

ship vw vh angle =
  sprite shipW shipH (0, 0) "assets/ship2.png" |> rotate angle
                                               |> scale 0.25

whiteTextForm string =
  text . T.color white <| toText string

debug key value =
  whiteTextForm <| key ++ ": " ++ (show value)

display : (Int,Int) -> GameState -> [[(Int,Int)]] -> Element
display (w,h) (GameState gameState) starTiles =
  let vp = viewPort (w,h,gameState.x,gameState.y)
      (left,top,right,bottom,ltr,ttb,sl) = starLayers vp starTiles
      displayLayers = [ background w h ] ++ sl ++ [ ship w h gameState.angle ]
  --in asText [vp, sl]
  --in container w h topLeft (collage w h displayLayers)
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

main = lift3 display dimensions gameState starTiles
