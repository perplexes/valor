module Subspace where
import Starfield

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
shipW = 170 / 4
shipH = 166 / 4

data UserInput = UserInput { x :: Int, y :: Int }

userInput =
  lift UserInput Keyboard.arrows

data Input = Input Float UserInput

data GameState = GameState { x :: Float, y :: Float, angle :: Float, dx :: Float, dy :: Float, t :: Float }

defaultGame = GameState { x=100.0, y=100.0, angle=0.0, dx=0.0, dy=0.0, t=0.0 }

stepGame (Input t (UserInput ui)) (GameState gs) =
  let {x,y,angle,dx,dy} = gs in
  GameState { gs | dx <- clamp (0-100) 100 (dx + toFloat ui.y * 2 * sin angle)
                 , dy <- clamp (0-100) 100 (dy + toFloat ui.y * 2 * cos angle * (0-1))
                 , angle <- angle + t * 3 * toFloat ui.x
                 , x <- clamp (shipW/2) (mapW - shipW/2) $ x + t * dx
                 , y <- clamp (shipH/2) (mapH - shipH/2) $ y + t * dy
                 , t <- t}

{- Display -}
{- For map tiles -}
{-
mapCols = 100
mapRows = 100
tileW = 64
tileH = 64
spriteMapW =
vTilesW = ceiling $ (toFloat viewW) / (toFloat tileW)
vTilesH = ceiling $ (toFloat viewH) / (toFloat tileH)
vTileWEven = viewW `mod` tileW == 0
vTileHEven = viewH `mod` tileH == 0

tile (c,r) = "bg01.png"

paddingW viewX =
  if vTileWEven && viewX `mod` tileW == 0 then 0 else 1
paddingH viewY =
  if vTileHEven && viewY `mod` tileH == 0 then 0 else 1

paintTiles (x, y) =
  let viewX = x - viewW/2,
      viewY = y - viewH/2,
      colsToPaint = vTilesW + paddingW viewX,
      rowsToPaint = vTilesH + paddingH viewY,
      left = floor $ viewX / (toFloat tileW),
      top = floor $ viewY / (toFloat tileH),
      right = ceiling $ viewX + viewW / (toFloat tileW),
      bottom = ceiling $ viewY + viewH / (toFloat tileH),
      xAdj = viewX - left * tileW,
      yAdj = viewY - top * tileH,

  map (\c -> map (\r -> tile c r xAdj yAdj) [left..right]) [top..bottom]

--context.drawImage(img,sx,sy,swidth,sheight,x,y,width,height);
tile c r xAdj yAdj =
  spriteMap "bg01.png" xAdj yAdj tileW tileH (c * tileW, r * tileH)

-}


background w h = filled black (rect w h (w/2,h/2))
ship vw vh angle =
  rotate (angle / (2 * pi)) $
    sprite "ship2.png" shipW shipH (vw/2 - shipW/2, vh/2 - shipH/2)

viewPort w h x y =
  let vx = x - (toFloat w)/2
      vy = y - (toFloat h)/2
  in (vx,vy,w,h)

whiteTextForm string =
  text . Text.color white $ toText string

debug key value =
  whiteTextForm $ key ++ ": " ++ show value

display (width,height) (GameState gameState) =
  let vp = viewPort width height gameState.x gameState.y
      (left,top,right,bottom,ltr,ttb,sl) = Starfield.starLayers vp
      w = floor width
      h = floor height
      displayLayers = [ background w h ] ++ sl ++ [ ship w h gameState.angle ]
  in container w h topLeft $ layers [
    collage w h displayLayers,
    flow down [
      debug "Viewport" vp,
      debug "Stars" (left,top,right,bottom,ltr,ttb),
      debug "gameState" gameState
    ]
  ]

delta = lift inSeconds (fps 30)
avgFPS = average 10 delta
input = sampleOn delta (lift2 Input delta userInput)

gameState = foldp stepGame defaultGame input

main = lift2 display Window.dimensions gameState
--main = asText randstar
