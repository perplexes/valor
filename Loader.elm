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

getTile : Object -> Int -> Int
getTile map index = findNumber (show index) map |> floor

--main = lift asText <| getJson "../svs/map.json"
