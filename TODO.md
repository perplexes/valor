- [x] modify to have devicePixelRatio
- [ ] how do I have a debug method/call out to console.log?!
- [x] I want a non-signal rand
- [ ] I want a spriteMap function that can crop into a sprite map
- [ ] I want list comprehensions. Or better understand partial application.
- [ ] Split into modules
- [ ] Include dotproduct assets as a dependency? Copy assets with attribution?
- [ ] Have someone make new hi-res Subspace assets
- [ ] JSON for settings to get all the consts out
- [x] Star tiles
- [ ] map tiles
- [ ] Ship moving around map (animations, etc)
- [ ] Animations for ship angles
- [ ] HUD
- [ ] collision detection
- [x] paintTiles should take viewport dimensions (x,y,w,h) cause they can change on resize
- [ ] move rect painting to fillRect when we can -
      a lot of objects are getting created/gc'd for the star field (which isn't necessary)
      possible work around is to blit (expose bliting?)
      ..better than just drawing the points all the time
- [ ] moar keys, keyb mappings

Language stuff:
- Maybe.elm (and other libs) don't have access to prelude/native.prelude, like #id

Wait for everything to load, show progress bar.
One shot signal that goes into a constant?

--

So "everything to load" is:
assets to preload
a bunch of shit to draw offscreen, then move onscreen once drawn

so we need a callback mechanism which is like

preload asset =
  load asset
  notify progressbar

progressbar is a total/done and can get a percent complete
map preload assets -- settings -> sprite maps, map (tile -> sprite), speeds, etc
spawn ship into free area (pick some x,y)
canvas = draw layers offscreen
  draw stars onto star tile canvases
  draw star tile canvases offscreen
  draw map/tiles offscreen
  draw ship offscreen
  draw HUD offscreen
swap progress screen with offscreen canvas

so my signal is: load.

--
notes about the stars:
drawing at /2 and /3 means the tiles are actually *2 and *3 the size (take that much longer to traverse)
so: is it faster to render like 300 stars, or prerender 2048 and 3072 tiles and then copy portions to the screen?


--
notes about ajax & json
http requests are handled as a signal. Main you can think of as a prime mover for signals. It will start the signal.
the output of the http request (since it's a signal) might change from Waiting, to Success or Error and you have to handle those.

so:
main = sendGet url

oh, but url needs to be a signal too, 'cause that could change, I guess:
main = sendGet (constant url)

so that will emit a Response, which is an ADT with Success string,
so you need like

handleAjax : Response -> somethin
handleAjax response =
  case response of
    Success json/html -> do something with json/html that matches the type of somethin
    Waiting -> Do a waiting text or something
    Failure code error -> Do something with the error code I guess

so we could do a
data JsonResponse a = JsonObject a | Waiting | Failure Int String

handleAjax : Response -> JsonResponse
handleAjax response =
  case response of
    Success json -> Json.fromString json
    Waiting -> response
    Failure _ _ -> response

then have something that handles jsons

handleJson : JsonResponse -> (something? record??)
handleJson response =
  case respose of
    JsonObject object -> recordFromJSString object

---

gamestate has a "STATE" field or something that is like
Loading | Paused | Running

if we're in the loading state, we display the progress bar. if the progress bar is 100%, we do the display swap.

the thing that gives us that state is a signal, a continually updating function which starts with init/main

loading : Signal { total:Int, done:Int, assets:??? }
loading = mapping/merging several signals to be done and update the total somehow.

or there are tasks, and somehow we wait for all tasks to get done.


main = lift3 display dimensions gameState loader

and display can take care of displaying the loading screen while things get loaded. I just have no idea what loader would look like.

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


---
well all that loader stuff is interesting and probably how I want it to end up, but for now I just want to draw a map.
So: load the json into the page or something.
problem: I can't make the main drawing thing wait for it to load, unless I can.
a signal that starts off with state=loading, then receives an event from JS saying "Loaded" with all the assets in some sort of record... thing.
--

the http/json story sucks and makes me think I'm doing it wrong.
