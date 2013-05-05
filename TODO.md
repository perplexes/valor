Random todos
------------
- [x] modify to have devicePixelRatio
- [ ] how do I have a debug method/call out to console.log?!
- [ ] Split into modules
- [ ] Include dotproduct assets as a dependency? Copy assets with attribution?
- [ ] Have someone make new hi-res Subspace assets
- [ ] JSON for settings to get all the consts out
- [x] Star tiles
- [ ] map tiles (load json, map tiles, draw in correct location)
- [ ] Ship moving around map (animations, etc)
- [ ] Animations for ship angles
- [ ] HUD
- [ ] collision detection
- [x] paintTiles should take viewport dimensions (x,y,w,h) cause they can change on resize
- [ ] moar keys, keyb mappings

Performance
-----------
- [ ] is it faster to render like 300 stars, or prerender 2048 and 3072 tiles and then copy portions to the screen?
- [ ] move rect painting to fillRect when we can -
      a lot of objects are getting created/gc'd for the star field (which isn't necessary)
      possible work around is to blit (expose bliting?)
      ..better than just drawing the points all the time

Language stuff
--------------
- [ ] Maybe.elm (and other libs) don't have access to prelude/native.prelude, like #id
- [x] I want a non-signal rand (this is wrong)
- [ ] Replace non-signal rand with signal'd rand.
- [ ] I want a spriteMap function that can crop into a sprite map (experiment with 0.8)
- [ ] I want list comprehensions. Or better understand partial application.

