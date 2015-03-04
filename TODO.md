# Todos
- [x] Move JS init into file (translate into cs)
- [x] draw ship in middle of screen
- [x] try to rotate ship when resp to keyboard events (need jquery?)
- [x] star field
- [x] update ship dx/dy, x,y when up/down
- [x] move star field
- [x] draw map
- [ ] move submodules out, just have the files. (or find on npm)
- [x] rb tree, zorder, impl query
-- divide tiles into z-regions to keep overhead down?
- [ ] maybe impl quadtree too to perf test
- [x] coll detection
- [ ] improve collision resolution (sometimes bounce is just way too much)
- [ ] flesh out a spec for the game
- [x] animation sprites, ship first
- [ ] use super pixels/clamp rendering to pixels not sub pixels
- [ ] other map tiles (space station, asteroid, animated asteroid)
- [s] tile metadata (colliding/no) [don't know where to get it - part of server settings?]
- [x] safe zone stopping
- [ ] prize boxes
- [ ] - powerups to get
- [ ] - full charge, energy depleted, shutdown, bullet upgrade, bomb upgrade, repel, burst, multiprize, shields, superpower, etc
- [ ] - bounty
- [ ] thrust trails
- [ ] bullets (bouncy/non, coll det for walls/players, random damage, multifire,)
- [ ] bombs (same, shrapnel)
- [ ] mines (same)
- [ ] repel/burst (l4 bullets, only after a bounce)
- [ ] stealth/xradar
- [ ] antiwarp
- [ ] EMP
- [ ] afterburner
- [ ] attach/spectator mode
- [ ] using different ships
- [ ] banners
- [ ] decoy
- [ ] doors (both map and team walls)
- [ ] portal/warping
- [ ] rockets
- [ ] audio
- [ ] thor's hammer
- [ ] configuration with yaml
- [ ] debug config pane to adjust paramaters during gameplay, serialize to yaml (but in same order as old config)

# Bugs
- [ ] improve collision resolution part 2: bullets can go through walls

# Random
- [ ] Use vendorer ruby gem for the js vendor files.
- [ ] Figure out require.js
- [ ] Use tamper for asset json, package asssets all together?
- [ ] Assets.json ... hson?
- [ ] assets json for movies within tilesets (tiles.bmp force fields, bullets have like 10 movies inside it)

# Research
- [x] pixi.js
- [ ] JS rbtree implementations

# Ideas
Different trees for static/dynamic objects
Look over GEA for module ideas
Movable list, collidable list
in movables, they must specify things they can collide with
maybe collision agent/target?
Ship (movable):
  [Tile, Bullet, Bomb, Mine]

Tile (collidable)

Bullet (movable, collidable):
  [Ship, Tile]

so then collision goes:
movables.each a
  movable.near.collidable.each b
    if collision? a, b
      resolve a, b

then what about shields? do those bounce bullets?

that's only directly touching, there are also aoe - like repel, which would have a different search/collide parameter (radius?)

should it be up to the movable class to deal with resolution?
ghost ship would be like ship but shouldn't be in the collision step (it's "not movable")
are there better terms than these?

All game objects (entity?) should have:
x, y (center)
w, h
hw, hh
so that we can calculate bounding boxes
we can trim two calculations by moving to UL x,y (-hw, -hh, +hw, +hh) -> (+w, +h)
but collision is from the center of things

Deformable map but hitting blocks, and keep it that way, reset every night or something

x Use callbacks instead of returning arrays of things
Object pooling
x bind extent obj to things that need it so we don't need to make new functions to capture the scope

Different layers for selfship/othership

Show tile damage, battle scars

--
x network reconcil. is still janky, probably because we're not doing smoothing, but it could be something else.
On this MBA 2014 w/ Ubuntu, FPS is down to 20. need to test on other machines.

x you can go through walls if you're going fast enough. this is something like

max speed (500px/s) / server physics speed (100ms, or 10 times/s)

if our block width is 16 px, then, what is the maximum speed at this physics timing?

30fps =~ 500px/s if the largest colliding block is 16px (to not have it totally go through - but if it's mid-way, then it's more frequent)

(increased server loop fps :/)

need reconnect/disconnect

Received negative timestamp on client - why?

WebRTC looks ready http://www.html5rocks.com/en/tutorials/webrtc/datachannels/

Also capnproto, need to make my own in JS/CS I guess.


--
2/27/15

Screen size isn't getting detected correctly.
Consider updateing pixi again

--
3/1/15

Ah, figured out the screen size issue. Just had to rearrange where we detect it.
Update pixi, that went fine.
Fixed the map - just needed to get jparser/jdataview under npm control

Okay: I want things to move pixel by pixel, so I need to get rid of floats entirely. This is part of a larger push toward deterministic physics and rendering. IIRC, the z-tree was preventing this because it has a limit on integer size of 65535 without some futzing.

Map sizes are ..

Ah, we could have multiple 
