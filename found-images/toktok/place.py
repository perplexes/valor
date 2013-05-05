# testing arena placing in py (?go)

from asss import *

# can't figure this out.
# the arena it sends to is different every time you start asss
# example arena name: 'txxxxxx'
# also asss usually deadlocks after typing ?go when this module is loaded
def place(p):
    x = 0
    y = 0
    return 1, "hello", x, y

# had to put ', None' otherwise it complained it wasn't a tuple
place_myint = reg_interface(I_ARENAPLACE, (place, None))
