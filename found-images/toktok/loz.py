# loz - legend of zelda by smong (woo!)
# inital version mar 7 2005

from asss import *

chat = get_interface(I_CHAT)
game = get_interface(I_GAME)
prng = get_interface(I_PRNG)

# must have at least 2 i think
welcome_msgs = [ "Once upon a time...", \
                 "Here be dragons.", \
                 "Got Ganon?", \
                 "Welcome back to Hyrule, Link! You may return to slaying.", \
                 "Welcome back to hyrule! Return to your quest and save the Princess.", \
                 "Welcome back to Hyrule! Kill link to begin your quest.", \
                 "Welcome back Link! The princess awaits." ]

items = [ ("L1 Sword", PRIZE_BOMB, 1), \
          ("L2 Sword", PRIZE_BOMB, 2), \
          ("L3 Sword", PRIZE_BOMB, 3), \
          ("L1 Bow", PRIZE_GUN, 1), \
          ("L2 Bow", PRIZE_GUN, 2), \
          ("Whistle", PRIZE_WARP, 1) ]

# this enum must match the list above
ITEM_L1_SWORD = 0
ITEM_L2_SWORD = 1
ITEM_L3_SWORD = 2
ITEM_L1_BOW = 3
ITEM_L2_BOW = 4
ITEM_WHISTLE = 5

# to store all the things you hold for re-prizing
class Inventory:
    def __init__(me):
        me.items = []
	me.hearts = 3
	me.rupees = 0
	me.level = SHIP_WARBIRD

    # prizes all the items
    def initial(me, p):
        # don't take any chances
        game.ShipReset(p)

        for i in me.items:
            if i.prize and i.count:
                game.GivePrize(p, i.prize, i.count)

    # prizes just one item
    def add_item(me, p, iid):
        # already have a sword, swap it
        if iid >= ITEM_L1_SWORD and iid <= ITEM_L3_SWORD:
            for id in me.items:
                if id >= ITEM_L1_SWORD and id <= ITEM_L3_SWORD:
                    # deprize it
                    name, prize, count = items[id]
                    if prize and count:
                        game.GivePrize(p, - prize, count)
                    # remove it
                    me.items.remove(id)
                    break

        # already have a bow
        if iid >= ITEM_L1_BOW and iid <= ITEM_L2_BOW:
            for id in me.items:
                if id >= ITEM_L1_BOW and id <= ITEM_L2_BOW:
                    # deprize it
                    name, prize, count = items[id]
                    if prize and count:
                        game.GivePrize(p, - prize, count)
                    # remove it
                    me.items.remove(id)
                    break

        # add the new item to the list
        me.items.append(iid)

        # prize the new item
        name, prize, count = items[iid]
        if prize and count:
            game.GivePrize(p, prize, count)

    def get_item_string(me, p):
        str = ""
        for i in me.items:
            str += items[i][0] + ", "
        if len(str) > 2:
            str = str[:-2]
        return str

class Shop:
    # topleft x,y including rock border, greet message, costs, item id's
    def __init__(me, x, y, gm, cost, iid):
        me.x = x
        me.y = y
        me.gm = gm
        me.cost = cost
        me.iid = iid

    # returns True if p is inside this shop
    # x and y must be in tile coords
    def is_inside(me, p, x, y):
	if x >= me.x and x < me.x + 32 and \
	    y >= me.y and y < me.y + 27:
	    return True
	else:
	    return False

    # greet the player
    def try_greet(me, p, x, y):
        #if now - p.loz_lastgreeted > 10000:
        #    chat.SendMessage(p, "%s" % me.gm)
        #    p.loz_greeted = now
        pass

    # tries to sell an item to p
    # x and y must be in tile coords
    def try_sell(me, p, x, y):
        x -= 11
        y -= 11
        counter = 0
        while counter < len(me.iid):
            if x >= me.x and x < me.x + 2 and \
                y >= me.y and y < me.y + 3:
                if p.loz_inv.rupees >= me.cost[counter]:
                    p.loz_inv.rupees -= me.cost[counter]
                    p.loz_inv.add_item(p, me.iid[counter])
                else:
                    chat.SendMessage(p, "come back when you have more Rupees.")
                break
            counter += 1
            x -= 4

def paction(p, action, arena):
    if action == PA_ENTERARENA:
    	# let people keep their stats until they reconnect,
	# so they can move between arenas.
    	try:
	    if p.loz_inv.rupees:
                pass
            r = prng.Number(0, len(welcome_msgs) - 1)
	    chat.SendMessage(p, "%s" % welcome_msgs[r])
	except AttributeError:
	    chat.SendMessage(p, "Welcome to Hyrule, you may begin your quest.")
            p.loz_inv = Inventory()

        # always reset these
        p.loz_incave = False
        #p.loz_greeted = False

def safezone(p, x, y, entering):
    if entering:
        # convert pixel to tile coords
        x = x >> 4
        y = y >> 4

        for area in p.arena.loz_areas:
            if area.is_inside(p, x, y):
                area.try_greet(p, x, y)
                area.try_sell(p, x, y)

def green(p, x, y, prize):
    # 1 in 20 will be worth 5 rupees!
    if prng.Rand() % 20 == 0:
        p.loz_inv.rupees += 5
    else:
        p.loz_inv.rupees += 1

    # limit to 999 rupees max
    if p.loz_inv.rupees > 999:
        p.loz_inv.rupees = 999

def c_inventory(cmd, params, p, targ):
    """\
Module: <py> zelda
Shows you your inventory.
"""
    chat.SendMessage(p, "-- The Legend of Zelda --")

    items = p.loz_inv.get_item_string(p)

    if len(items) > 0:
        chat.SendMessage(p, "Items: %s" % items)
    else:
        chat.SendMessage(p, "You have no items! Go and hunt around for some.")

    chat.SendMessage(p, "-- %3d Rupees          --" % p.loz_inv.rupees)
    #chat.SendMessage(p, "-- Zelda is waiting..  --")

def load_areas(arena):
    mylist = []

    # extract from Shop class:
    # topleft x,y including rock border, greet message, costs, item id's

    mylist.append(Shop(2, 996, "Buy somethin' will ya!", \
        [1, 2, 3], [ITEM_L1_SWORD, ITEM_L2_BOW, ITEM_WHISTLE]))

    return mylist

def mm_attach(arena):
    arena.loz_ref1 = reg_callback(CB_PLAYERACTION, paction, arena)
    arena.loz_ref2 = reg_callback(CB_SAFEZONE, safezone, arena)
    arena.loz_ref3 = reg_callback(CB_GREEN, green, arena)
    arena.loz_ref4 = add_command("inv", c_inventory, arena)
    arena.loz_areas = load_areas(arena)

def mm_detach(arena):
    for i in range(4):
        try: delattr(a, 'loz_ref%d' % (i+1))
        except: pass

    try: delattr(a, 'loz_areas')
    except: pass

