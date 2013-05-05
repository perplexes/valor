# demo asss python module
# dec 28 2004 smong

# nearly always use this
from asss import *


# get some interfaces
# see chat.h for where I_CHAT comes from, see other .h files for more (fx: game.h)
chat = get_interface(I_CHAT)


# a callback
# this function is called when a player enters/leaves, see core.h for PA_??? constants
def paction(p, action, arena):
    # start indenting
    if action == PA_ENTERARENA:
        # see chat.h for the names of more functions like SendMessage
        chat.SendMessage(p, "hello")
        # i'm not sure which one of these is correct, you will have to experiment
        # see player.h for more p.??? fields
        #chat.SendMessage(p, "1) hello %s", p.name)
        #chat.SendMessage(p, "2) hello %s" % p.name)
        #chat.SendMessage(p, "3) hello ", p.name)
        #chat.SendMessage(p, ( "4) hello ", p.name ))

# tell asss to call 'paction' when CB_PLAYERACTION is signalled
# see .h files for CB_??? names
cb1 = reg_callback(CB_PLAYERACTION, paction)


# a command
# see cmdman.h for what each parameter does
def c_moo(cmd, params, p, targ):
# help text (?help moo). may have to move this comment somewhere else if it won't run.
    """\
Module: <py> demo
Targets: none
a sample command.
"""
    chat.SendMessage(p, "moo")

# tell asss to call 'c_moo' when a player types ?moo
# note: add cmd_moo to conf/groupdef.dir/default so players have permission to use this
#  command.
cmd1 = add_command("moo", c_moo)


# now make you own module
# i recommend writing on paper what you would do if you were hosting this event manually,
#  then look at the .h files to find the callbacks you need (like shipchange, kill, etc)
# look at the asss console for execution errors, and if that doesn't help, add some
#  chat.SendArenaMessage("i'm at line ...") type messages to locate the buggy piece of code

