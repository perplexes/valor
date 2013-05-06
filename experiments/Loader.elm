{- XXX: Not used yet -}
module Loader where
import Http
import Json
import Dict as Dict
--import Native.Json as Native
--stageCombine loadedRecord lastRecord =
--  if lastRecord.done + 1 == total then
--    --... we're done loading, switch canvases
--  else
--    { lastRecord | done <- done + 1 }

--loader : Signal { done:Int, settings:{} }
--loader = foldp stageCombine {} merge [
--  assetLoader <| sendGet <| constant "assets.json"
--  mapLoader <| sendGet <| constant "map.json"
--  settingsLoader <| sendGet <| constant "settings.json"
--]

stringToJson : String -> Value
stringToJson string = fromMaybe Json.Null (Json.fromString string)

httpToJson : Response -> Response
httpToJson response =
  case response of
    Success json -> Success (stringToJson json)
    _ -> response

getJson : String -> Signal Response
getJson url = httpToJson <~ (sendGet <| constant url)

--
--getTile (Object map) tile = findNumber (show tile) map

getTile : Response -> Float
getTile response =
  case response of
    Success (Object map) -> findNumber "3" map
    _ -> toFloat (0-1)

--main = lift asText <| getJson "../svs/map.json"
main = lift asText <| lift getTile (getJson "../svs/map.json")
