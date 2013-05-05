# points_goal by smong
# just goal mode 1 for now with a custom scoring system.
# (currently only accepts absolute scores).
# settings:
# [Soccer]
# ; 10 goals needed to win the game reward
# CapturePoints=-10
# ; team reward per goal (negative means absolute value)
# Reward=-100
# ; personal reward goes to the scorer
# PersonalReward=-200
# ; team reward when
# GameReward=-1000
#
# [Misc]
# ; 15 minutes until the goal counts are reset
# TimedGame=90000
#
# inital version feb 6 2005

from asss import *

cfg = get_interface(I_CONFIG)
chat = get_interface(I_CHAT)
stats = get_interface(I_STATS)

def aaction(arena, action):
    if action == AA_CREATE or action == AA_CONFCHANGED:
    	read_settings(arena)

cb1 = reg_callback(CB_ARENAACTION, aaction)

def make_timer(initial, interval, arena):
    def pg_timer():
    	reset_game(arena)
	chat.SendArenaSoundMessage(arena, SOUND_DING, "Soccer game over.")
    return set_timer(pg_timer, initial, interval)

def read_settings(arena):
    arena.pg_timedgame = cfg.GetInt(arena.cfg, "Misc", "TimedGame", 0)
    arena.pg_capturepoints = cfg.GetInt(arena.cfg, "Soccer", "CapturePoints", -10)
    arena.pg_reward = cfg.GetInt(arena.cfg, "Soccer", "Reward", -100)
    arena.pg_personalreward = cfg.GetInt(arena.cfg, "Soccer", "PersonalReward", -200)
    arena.pg_gamereward = cfg.GetInt(arena.cfg, "Soccer", "GameReward", -1000)

def reset_game(arena):
    arena.pg_goals = [ 0, 0 ]
    arena.pg_ref = None
    if arena.pg_timedgame:
    	arena.pg_ref = make_timer(arena.pg_timedgame, \
	    arena.pg_timedgame, arena)

def goal(arena, p, bid, x, y):
    # increment score
    team = p.freq % 2
    arena.pg_goals[team] += 1

    # reward
    points = 0
    if arena.pg_reward < 0:
    	points = - arena.pg_reward

    def reward_points(i):
    	if i.arena == arena and is_standard(i) and p.ship != SHIP_SPEC:
	    if i.freq == p.freq:
    	    	stats.IncrementStat(p, STAT_FLAG_POINTS, points)
    	    	stats.IncrementStat(p, STAT_BALL_GAMES_WON, 1)
		chat.SendSoundMessage(i, SOUND_GOAL, \
		    "Team Goal! by %s  Reward:%d" % (p.name, points))
    	    else:
    	    	stats.IncrementStat(p, STAT_BALL_GAMES_LOST, 1)
		chat.SendSoundMessage(i, SOUND_GOAL, \
		    "Enemy Goal! by %s  Reward:%d" % (p.name, points))
    for_each_player(reward_points)

    # personal reward
    if arena.pg_personalreward < 0:
    	chat.SendArenaMessage(arena, "Personal reward: %d" % \
	    - arena.pg_personalreward)
        stats.IncrementStat(p, STAT_FLAG_POINTS, - arena.pg_personalreward)

    # check for a win
    winpoints = 0
    if arena.pg_capturepoints < 0:
        winpoints = - arena.pg_capturepoints

    if arena.pg_goals[team] >= winpoints:
    	# game reward
	points = 0
    	if arena.pg_gamereward < 0:
    		points = - arena.pg_gamereward

    	def game_reward_points(i):
	    if i.arena == arena and is_standard(i) and p.ship != SHIP_SPEC:
	    	if i.freq == p.freq:
		    stats.IncrementStat(p, STAT_FLAG_POINTS, points)
	for_each_player(game_reward_points)

	chat.SendArenaMessage(arena, "Game reward: %d" % points)

    	reset_game(arena)
	chat.SendArenaSoundMessage(arena, SOUND_DING, "Soccer game over.")

    stats.SendUpdates()

def mm_attach(arena):
    read_settings(arena)
    reset_game(arena)
    arena.pg_ref1 = reg_callback(CB_GOAL, goal, arena)

def mm_detach(arena):
    arena.pg_ref1 = None

