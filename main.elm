module Subspace where

clamp min max x =
  if | x < min -> min
     | x < max -> x
     | otherwise -> max

mapW = 600
mapH = 600

data UserInput = UserInput { x :: Int, y :: Int }

userInput =
  lift UserInput Keyboard.arrows

data Input = Input Float UserInput

data GameState = GameState { x :: Float, y :: Float, angle :: Float, dx :: Float, dy :: Float }

defaultGame = GameState { x=100.0, y=100.0, angle=0.0, dx=0.0, dy=0.0 }

stepGame (Input t (UserInput ui)) (GameState gs) =
  let {x,y,angle,dx,dy} = gs in
  GameState { gs | dx <- dx + toFloat ui.y * sin angle
                 , dy <- dy + toFloat ui.y * cos angle * (0-1)
                 , angle <- angle + t * 3 * toFloat ui.x
                 , x <- clamp 0 mapW $ x + t * dx
                 , y <- clamp 0 mapH $ y + t * dy}

{- Display -}
background w h = filled (rgb 220 220 220) (rect w h (0,0))
ship x y angle = rotate (0.08 + (angle / (2 * pi))) (filled black (ngon 3 10 (x,y)))

display (w,h) (GameState gameState) =
  container w h middle $
    layers [
      collage w h $
        [ background w h, ship gameState.x gameState.y gameState.angle]
        , asText gameState
    ]
-- display (w,h) gameState = asText gameState

delta = lift inSeconds (fps 60)
input = sampleOn delta (lift2 Input delta userInput)

gameState = foldp stepGame defaultGame input

main = lift2 display Window.dimensions gameState
