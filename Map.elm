module Map where
import HTTP
import JSON

detail =
  let toRequest s = get $ "http://zip.elevenbasetwo.com/v2/US/" ++ s in
  lift extract (send (lift toRequest zipCode))

extract response =
  case response of
    Success json -> plainText . findString "city" $ fromString json
    Waiting -> image 16 16 "waiting.gif"
    Failure _ _ -> asText response

display info =
  flow right [ zipPicker, plainText " is the zip code for ", info ]

main = lift display detail

case (sendGet "svs/map.json") of
  Success json -> renderMap $ fromString json

{- For map tiles -}
{-
mapCols = 100
mapRows = 100
tileW = 64
tileH = 64
spriteMapW =
vTilesW = ceiling <| (toFloat viewW) / (toFloat tileW)
vTilesH = ceiling <| (toFloat viewH) / (toFloat tileH)
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
      left = floor <| viewX / (toFloat tileW),
      top = floor <| viewY / (toFloat tileH),
      right = ceiling <| viewX + viewW / (toFloat tileW),
      bottom = ceiling <| viewY + viewH / (toFloat tileH),
      xAdj = viewX - left * tileW,
      yAdj = viewY - top * tileH,

  map (\c -> map (\r -> tile c r xAdj yAdj) [left..right]) [top..bottom]

--context.drawImage(img,sx,sy,swidth,sheight,x,y,width,height);
tile c r xAdj yAdj =
  spriteMap "bg01.png" xAdj yAdj tileW tileH (c * tileW, r * tileH)

-}
