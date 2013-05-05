# persist demo (per-player)
# ?t1 to see current value
# pickup a green to increase it
# initial value is 500

from asss import *

chat = get_interface(I_CHAT)

def paction(p, action, arena):
    if action == PA_ENTERGAME:
        chat.SendMessage(p, "value: %d" % p.save_value)

cb1 = reg_callback(CB_PLAYERACTION, paction)


def green(p, x, y, prize):
    p.save_value += 1

cb2 = reg_callback(CB_GREEN, green)


def c_showme(cmd, params, p, targ):
    chat.SendMessage(p, "value: %d" % p.save_value)

cmd1 = add_command("t1", c_showme)


# persist stuff

def getd(p):
    return p.save_value

def setd(p, d):
    p.save_value = d

def cleard(p):
    # this is the initial value
    p.save_value = 500

mypd = reg_player_persistent(
	1853, INTERVAL_RESET, PERSIST_GLOBAL,
	getd, setd, cleard)

