#Leader by Chambahs
#12-16-05
#dec 29 2005 smong

from asss import *

chat = get_interface(I_CHAT)
game = get_interface(I_GAME)

def count_playing(arena):
    players = [ 0 ]
    def cb_count(p):
        if p.arena == arena and p.ship < SHIP_SPEC:
             players[0] += 1
    for_each_player(cb_count)
    return players[0]

def kill(arena, killer, killed, bounty, flags, pts, green):
    # promote
    if killer.ship != SHIP_WARBIRD:
        game.SetShip(killer, killer.ship - 1)

    # check for game over
    elif killer.ship == SHIP_WARBIRD:
        arena.leader_killcb = None
        chat.SendArenaMessage(arena, "Game over. %s is the winner!" % killer.p.name)

    # demote
    if killed.ship != SHIP_SHARK:
        game.SetShip(killed, killed.ship + 1)

    return pts, green

def c_start_game(cmd, params, p, targ):
    """\
Module: <py> leader
Min. players: 2
Everyone starts as Shark, kill to get ship changed.
First to make a kill in a Warbird wins.
"""
    players = count_playing(p.arena)

    if players >= 2:
        def cb_setship(i):
            if i.arena == arena and i.ship < SHIP_SPEC:
                game.SetShip(i, SHIP_SHARK)
        for_each_player(cb_setship)

        chat.SendArenaMessage(p.arena, "The Game Has Started, Begin Killing To Get Promoted. If You Are Killed You Will Get Demoted.")
        game.LockArena(p.arena, 0, 0, 0, 0)
        p.arena.leader_killcb = reg_callback(CB_KILL, kill, p.arena)
    else:
        chat.SendMessage(p, "Not enough players, %d more needed." % (2 - players))

cmd1 = add_command("startl", c_start_game)

