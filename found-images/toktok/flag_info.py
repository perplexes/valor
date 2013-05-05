# flag_info by smong
# announces flag locations periodically. ported from flag_info.c
# default settings:
# Flag:NotifySeconds=6000
#
# inital version feb 5 2005

from asss import *

cfg = get_interface(I_CONFIG)
chat = get_interface(I_CHAT)
flagcore = get_interface(I_FLAGCORE)

def count_playing(arena, incspec, incsafe):
    count = [ 0 ]
    def for_each(p):
    	if p.arena == arena and \
	    (incspec or p.ship != SHIP_SPEC) and \
	    (incsafe or not (p.position[6] & STATUS_SAFEZONE)):
       	    count[0] += 1
    for_each_player(for_each)
    return count[0]

def add_flag(set, x, y):
    x = (x * 10) / 512
    y = (y * 10) / 512
    pos = [ x, y, 1 ]

    for flag in set:
    	if flag[0] == pos[0] and flag[1] == pos[1]:
	    # increment count
	    flag[2] += 1
	    break
    else:
    	set.append(pos)

# returns a modified msg
def append_flag_info(msg, set):
    done = [ 0 ]
    size = len(set)

    for pos in set:
    	x, y, count = pos

    	if count > 1:
	    msg += " %d at" % count

    	# construct coord
	msg += " %c%d" % ( ord('A') + x, y + 1 )

    	# append a comma unless it is the last one
	if done[0] + 1 < size:
	    msg += ","

    	done[0] += 1

    return msg



def make_timer(initial, interval, arena):
    def timer():
    	nuetset = []
	dropset = []

    	# don't spam if one is playing
    	if count_playing(arena, False, True) < 1:
	    return 1

    	i = 0
    	n, f = flagcore.GetFlags(arena, i)
    	while n:
	    if f.state == FI_ONMAP:
	    	if f.freq == -1:
		    add_flag(nuetset, f.x, f.y)
		else:
		    add_flag(dropset, f.x, f.y)
	    # setup for the next loop cycle
	    i += 1
	    n, f = flagcore.GetFlags(arena, i)

    	msg = "NOTICE: "
        if len(nuetset) > 0:
	    msg += "Nuets"
	    msg = append_flag_info(msg, nuetset)
	    msg += ". "
        if len(dropset) > 0:
	    msg += "Drops"
	    msg = append_flag_info(msg, dropset)
	    msg += ". "

    	# don't send a message if all flags are carried
    	if len(msg) > 8:
	    chat.SendArenaMessage(arena, msg)
    return set_timer(timer, initial, interval)


def mm_attach(arena):
    interval = cfg.GetInt(arena.cfg, "Flag", "NotifySeconds", 6000) * 100;
    arena.flaginfo_ref = make_timer(3000, interval, arena)

def mm_detach(arena):
    arena.flaginfo_ref = None

