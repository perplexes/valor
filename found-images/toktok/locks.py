# set ship/freq deadlock test module
# apr 10 2005 smong

from asss import *

chat = get_interface(I_CHAT)
game = get_interface(I_GAME)

def c_t1(cmd, params, p, targ):
    """\
Module: <py> locks
Args: [freq|ship|both]
This module will either setship, setfreq or both on the whole arena.
The default ation is setfreq.
"""
    if params == "ship":
        def cb_setship(p):
            game.SetShip(p, SHIP_WARBIRD)
        for_each_player(cb_setship)
    elif params == "both":
        def cb_setfreqandship(p):
            game.SetFreqAndShip(p, SHIP_WARBIRD, 0)
        for_each_player(cb_setfreqandship)
    else:
        def cb_setfreq(p):
            game.SetFreq(p, 0)
        for_each_player(cb_setfreq)

cmd1 = add_command("t1", c_t1)

