# fg_ctf first attempt by smong on feb 18 2005

from asss import *

flagcore = get_interface(I_FLAGCORE)
mapdata = get_interface(I_MAPDATA)
chat = get_interface(I_CHAT)

spawns = [ (436, 511), (585, 511) ]
regions = [ "zero", "one" ]

def afunc(p, rgn):
    chat.SendMessage(p, "%s" % mapdata.RegionName(rgn))

def make_region_timer(arena, initial, interval):
    rgn1 = mapdata.FindRegionByName(arena, "zero")
    rgn2 = mapdata.FindRegionByName(arena, "one")

    def region_timer():
        def for_each(p):
            if p.status == S_PLAYING and p.arena and p.ship != SHIP_SPEC:
                #try:
                    x = p.position[0] >> 4
                    y = p.position[1] >> 4

                    # debug
                    chat.SendMessage(p, "hello! %s %s %d %d %s %s" % \
                        (regions[0], regions[1], x, y, rgn1, rgn2))

                    #mapdata.EnumContaining(arena, -1, -1, afunc, p)

                    if rgn1 and mapdata.Contains(rgn1, x, y):
                        chat.SendMessage(p, "in region: %s" % regions[0])

                    if rgn2 and mapdata.Contains(rgn2, x, y):
                        chat.SendMessage(p, "in region: %s" % regions[1])
                #except:
                #    pass
        for_each_player(for_each)

    return set_timer(region_timer, initial, interval)

# moves the flag back to the base after a little while
def make_respawn_timer(arena, fid, initial):
    pass

# moves the flag back to the base and sets the ownership
def respawn_flag(arena, fid):
    pass

# when a player is killed while holding a flag (or sc'd, fc'd, left)
def nuet_flag(arena, fid, x, y):
    pass

# checks to see if the flag carriers should drop their flag
def check_flags(arena):
    pass

# checks to see if two flags are owned and in the same region
def check_win(arena):
    pass

# resets the flag game. moves the flags to their base spawns.
def reset(arena):
    pass

# the flaggame interface

def init(arena):
    flagcore.SetCarryMode(arena, CARRY_ALL)
    flagcore.ReserveFlags(arena, 2)
    reset(arena)

def flagtouch(arena, p, fid):
    f = flaginfo()
    f.state = FI_CARRIED
    f.carrier = p
    flagcore.SetFlags(a, fid, f)

def cleanup(arena, fid, reason, carrier, freq):
    f = flaginfo()
    f.state = FI_NONE
    f.carrier = None
    f.x = carrier.position[0] >> 4
    f.y = carrier.position[1] >> 4
    f.freq = freq
    flagcore.SetFlags(arena, fid, f)

myflaggame = (init, flagtouch, cleanup)

# attaching/detaching

def mm_attach(arena):
    try:
        arena.fg_ctf_ref1 = reg_interface(I_FLAGGAME, myflaggame, arena)
        arena.fg_ctf_ref2 = make_region_timer(arena, 400, 200)
    except:
        mm_detach(arena)

def mm_detach(arena):
    for attr in ['ref1', 'ref2']:
        try: delattr(a, 'fg_ctf_' + attr)
        except: pass

