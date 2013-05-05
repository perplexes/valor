# ?message by smong
# don't have this loaded if you are using a biller that has ?message
# data is stored as follows (sent time, read time, from name, lower(to name), message)
# july 26 2005

# how long before a read message is deleted (in seconds)
# should preferably be a multiple of global.conf Persist:SyncSeconds (180)
# 86400 = 1 day
purgeseconds = 86400
purgeseconds = 20 # debug

from time import *
from asss import *

chat = get_interface(I_CHAT)
pd = get_interface(I_PLAYERDATA)
lm = get_interface(I_LOGMAN)

msgs = []

def c_message(cmd, params, p, targ):
    """\
Module: <py> msg
Args: <player name>:<message>
Send a message to a player, even if they are offline.
"""
    if params:
        toname, msg = params.split(':', 1)

        #if toname and msg:

        toname = toname.lower()
        data = (time(), 0, p.name, toname, msg)

        # remove from list if theres one already there
        fromname = p.name.lower()
        for msg in msgs:
            _, _, fromname2, toname2, _ = msg
            # case insensitive match
            fromname2 = fromname2.lower()
            if fromname == fromname2 and toname == toname2:
                msgs.remove(msg)
                msgs.append(data)
                chat.SendMessage(p, "Previous message replaced")
                break
        else:
            msgs.append(data)
            chat.SendMessage(p, "Message stored")

        # find player incase already online
        rcp = pd.FindPlayer(toname)
        if rcp:
            chat.SendMessage(rcp, "You have 1 new message. Type ?messages to read")

cmd1 = add_command("message", c_message)


# pass in seconds, returns a time like [Jul 25 23:06]
def format_time(secs):
    return strftime("[%b %d %H:%M]", gmtime(secs))

def c_messages(cmd, params, p, targ):
    """\
Module: <py> msg
Displays any messages you may have.
"""
    name = p.name.lower()
    count = 0
    toremove = []
    toreadd = []

    # loop through all stored messages
    for msg in msgs:
        timesent, timeread, fromname, toname, msgtext = msg
        # case insensitive match
        if name == toname:
            # deferred remove and re-add as read
            if timeread == 0:
                toremove.append(msg)
                msg = (timesent, time(), fromname, toname, msgtext)
                toreadd.append(msg)
            chat.SendMessage(p, "%s %s: %s" % (format_time(timesent), fromname, msgtext))
            count += 1

    # remove messages marked as read outside other loops
    for msg in toremove:
        msgs.remove(msg)

    # re-add messages marked as read outside other loops
    for msg in toreadd:
        msgs.append(msg)

    if count == 0:
        # no messages displayed to user
        chat.SendMessage(p, "No messages")

cmd2 = add_command("messages", c_messages)


def count_unread_messages(name):
    name = name.lower()
    count = 0

    # loop through all stored messages
    for msg in msgs:
        _, timeread, _, toname, _ = msg
        # case insensitive match
        if name == toname and timeread == 0:
            count += 1

    return count

def paction(p, action, arena):
    if action == PA_ENTERGAME:
        count = count_unread_messages(p.name)
        if count == 1:
            chat.SendMessage(p, "You have 1 new message. Type ?messages to read")
        elif count > 1:
            chat.SendMessage(p, "You have %d new messages. Type ?messages to read" % (count))

cb1 = reg_callback(CB_PLAYERACTION, paction)


# deletes all messages marked as read that are older than purgeseconds
def purge():
    now = time()
    count = 0

    # loop through all stored messages
    for msg in msgs:
        _, timeread, _, _, _ = msg
        if timeread != 0 and (now - timeread) > purgeseconds:
            msgs.remove(msg)
            count += 1

    if count:
        # log this event. global.conf: log_sysop:msg = IMWE
        lm.Log(L_INFO, "<msg> purged %d read messages" % (count))


# persist

def getpd(a):
    purge()
    lm.Log(L_DRIVEL, "<msg> saving %d messages" % (len(msgs)))
    return msgs

def setpd(a, d):
    if a:
        lm.Log(L_DRIVEL, "<msg> loaded %d messages for arena '%s'" % (len(d), a.name))
    else:
        lm.Log(L_DRIVEL, "<msg> loaded %d messages" % (len(d)))
    msgs = d

def clearpd(a):
    if a:
        lm.Log(L_DRIVEL, "<msg> deleting %d messages for arena '%s'" % (len(d), a.name))
    else:
        lm.Log(L_DRIVEL, "<msg> deleting %d messages" % (len(d)))

    msgs = []

mypd = reg_arena_persistent(
	6538, INTERVAL_FOREVER, PERSIST_GLOBAL,
	getpd, setpd, clearpd)
