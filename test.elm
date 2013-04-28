--main = asText <| show (filled black (rect 1 1) |> move 100 100)
--adder : (Int,Int,Float,Float) -> Float
--adder (w,x,y,z) =
--  w * x + y / z
--main = asText <| [adder (1,1024,343.3,100.0), 1+1]
module Test where
import Http
import Json
import Dict as Dict

--getJson : Response -> String
--getJson response =
--  case response of
--    Waiting -> ""
--    Success json -> show <| Json.fromString json
--    Failure _ _ -> show <| Json.fromString ("{\"error\": \"error\"}")

-- Json.Null here could be a {state: Failure, error: "Couldn't parse JSON"}
stringToJson : String -> Value
stringToJson string = fromMaybe Json.Null (Json.fromString string)

httpToJson : Response -> Value
httpToJson response =
  let json = case response of
    Waiting -> "{\"state\": \"Waiting\"}"
    Success json -> "{\"state\": \"Success\", \"response\": "++json++"}"
    Failure code err -> "{\"state\": \"Failure\", \"error\": \""++err++"\"}"
  in stringToJson json

getJson : String -> Signal Value
getJson url = httpToJson <~ (sendGet <| constant url)

loadResources json =
  findObject "images" json

--lift loadResources (getJson "/svs/resources.json")

--main = lift (asText . getJson) (sendGet (constant "/svs/resources.json"))
--m a = Just a
--main = asText (fromMaybe 0 (m 1))
--main = lift asText <| getJson "/svs/resources.json"
--main = lift asText <| (lift loadResources <| getJson "/svs/resources.json")
dict : Dict String String
dict = Dict.fromList [("images", "somethin")]
main = asText <| Json.findString "images" dict
