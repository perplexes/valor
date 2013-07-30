module Loader where
import Http (Success, sendGet)
import Json (JsonValue, Null, toJSObject, findNumber, fromString)
import Maybe (Just, Nothing, maybe)
import JavaScript.Experimental as JS

stringToJson : String -> JSObject
stringToJson string = case fromString string of
  Just jsonValue -> JS.toRecord (toJSObject jsonValue)
  Nothing -> JS.fromRecord {}

httpToJson : Response -> Response
httpToJson response =
  case response of
    Success json -> Success (stringToJson json)
    _ -> response

getJson : String -> Signal Response
getJson url = httpToJson <~ (sendGet <| constant url)
