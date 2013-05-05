{- XXX: Not used yet -}
module Loader where
stageCombine loadedRecord lastRecord =
  if lastRecord.done + 1 == total then
    ... we're done loading, switch canvases
  else
    { lastRecord | done <- done + 1 }

loader : Signal { done:Int, settings:{} }
loader = foldp stageCombine {} merge [
  assetLoader <| sendGet <| constant "assets.json"
  mapLoader <| sendGet <| constant "map.json"
  settingsLoader <| sendGet <| constant "settings.json"
]
