{-
- [x] modify to have devicePixelRatio
- [ ] tell evan about the issue with latest Elm and this code, try to narrow down to smallest case
- [ ] latest elm-lang doesn't run on latest elm
- [ ] error messages are shit
- [ ] typing functions is awkward and there is no syntax help to do it
- [ ] how do I have a debug method/call out to console.log?!
- [ ] I want a non-signal rand
- [ ] I want a spriteMap function that can crop into a sprite map
- [ ] I want list comprehensions. Or better understand partial application.
- [ ] Split into modules
- [ ] Include dotproduct assets as a dependency? Copy assets with attribution?
- [ ] Have someone make new hi-res Subspace assets
- [ ] JSON for settings to get all the consts out
- [ ] Star tiles
- [ ] map tiles
- [ ] Ship moving around map (animations, etc)
- [ ] Animations for ship angles
- [ ] HUD
- [ ] collision detection
- [ ] paintTiles should take viewport dimensions (x,y,w,h) cause they can change on resize
-}
module Subspace where

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

data GameState = GameState { x :: Float, y :: Float, angle :: Float, dx :: Float, dy :: Float }

defaultGame = GameState { x=100.0, y=100.0, angle=0.0, dx=0.0, dy=0.0 }

stepGame (Input t (UserInput ui)) (GameState gs) =
  let {x,y,angle,dx,dy} = gs in
  GameState { gs | dx <- clamp (0-100) 100 (dx + toFloat ui.y * 2 * sin angle)
                 , dy <- clamp (0-100) 100 (dy + toFloat ui.y * 2 * cos angle * (0-1))
                 , angle <- angle + t * 3 * toFloat ui.x
                 , x <- clamp (shipW/2) (mapW - shipW/2) $ x + t * dx
                 , y <- clamp (shipH/2) (mapH - shipH/2) $ y + t * dy}

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

starTilesize = 1024
starDensity = 31
randstar _ = JavaScript.randInRange 0 starTilesize
starPoints = map (\x -> (randstar x, randstar x)) [0..starDensity]
starsLevel1 = starPoints -- closer
starsLevel2 = starPoints -- farther
l1color = rgb 184 184 184
l2color = rgb 96 96 96

starLayers (vx,vy,vw,vh) =
  let left = floor $ (vx - vw) / (toFloat starTilesize)
      top = floor $ (vy - vh) / (toFloat starTilesize)
      right = floor $ (vx + vw) / (toFloat starTilesize)
      bottom = floor $ (vy + vh) / (toFloat starTilesize)
      st (c,r) = starTile (c,r) (vx,vy,vw,vh)
  in foldl (\c a ->
       foldl (\r a2 ->
         a2 ++ st (c,r)
       ) a [left..right]
     ) [] [top..bottom]

starTile (c,r) (vx,vy,vw,vh) =
  let dx1 x = (c * starTilesize + x - vx + vw) / 2
      dy1 y = (r * starTilesize + y - vy + vh) / 2
      dx2 x = (c * starTilesize + x - vx) / 3 + vw/2
      dy2 y = (r * starTilesize + y - vy) / 3 + vh/2
      star color (x, y) = filled color (rect 1 1 (x,y))
  in map (\(x,y) -> star l1color (dx1 x, dy1 y)) starsLevel1 ++
     map (\(x,y) -> star l2color (dx2 x, dy2 y)) starsLevel2

background w h = filled black (rect w h (w/2,h/2))
--background w h = textured "hubble.jpg" (rect w h (0,0))
--ship x y angle = rotate (0.08 + (angle / (2 * pi))) (filled black (ngon 3 10 (x,y)))
ship vw vh angle =
  rotate (angle / (2 * pi)) $
    sprite "ship2.png" shipW shipH (vw/2 - shipW/2, vh/2 - shipH/2)

viewPort w h x y =
  let vx = x - (toFloat w)/2
      vy = y - (toFloat h)/2
  in (vx,vy,w,h)

whiteTextForm string =
  text . Text.color white $ toText string

display (width,height) (GameState gameState) =
  let sl = starLayers $ viewPort width height gameState.x gameState.y
      w = floor width
      h = floor height
      layers = [ background w h ] ++ sl ++ [ ship w h gameState.angle ] ++ [whiteTextForm $ "hello"]
  in container w h topLeft $ collage w h layers
  --in container w h topLeft $ collage w h $ [whiteTextForm $ show st] ++ [background w h] ++ st
  --in asText $ show (w,h,(viewPort width height gameState.x gameState.y),sl)
  --in asText $ show (background w h)
    --  --, text . Text.color
    --]
    --asText $ show gameState,
    --asText $ show (w,h)
  --]

--display (w,h) (GameState gameState) =
--  let vx = gameState.x - (toFloat w)/2
--      vy = gameState.y - (toFloat h)/2
--  in show $ randstar

delta = lift inSeconds (fps 30)
input = sampleOn delta (lift2 Input delta userInput)

gameState = foldp stepGame defaultGame input

main = lift2 display Window.dimensions gameState
--main = asText randstar
