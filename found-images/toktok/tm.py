# text mapper, ported by smong from cerium's hybrid plugin thingy
# jul 5 2006 initial version

from asss import *

CHAR_SPACE = 0x20
CHAR_ZERO = 0x30
CHAR_ONE = 0x31
CHAR_NINE = 0x39
CHAR_BETA = 0x80
CHAR_ESCAPE = ord('%')

OBJ_OFF = 0
OBJ_ON = 1

objs = get_interface(I_OBJECTS)
chat = get_interface(I_CHAT)

def isnum(char):
	char = ord(char)
	return char >= CHAR_ZERO and char <= CHAR_NINE

def buildTextMap(text, target, startobjectid, availableids):
	if text == None or availableids < 1:
		return

	color = 0
	strlen = len(text)
	objid = startobjectid

	i = 0
	j = availableids
	while i < strlen and j > 0:

		char = ord(text[i])

#		if char == CHAR_ESCAPE:
#			chat.SendArenaMessage(target, "escape: true")
#			if i + 1 < strlen:
#				chat.SendArenaMessage(target, "bounds: safe")
#				if isnum(text[i + 1]):
#					chat.SendArenaMessage(target, "isnum: true")

		# check for color
		if char == CHAR_ESCAPE and i + 1 < strlen and isnum(text[i + 1]):
			if i == 0 or text[i - 1] != CHAR_ESCAPE:
				# skip escape character
				i += 1
				char = ord(text[i])

				# check valid color (only 1 and 2 currently supported)
				if char - CHAR_ONE == 1 or char - CHAR_ONE == 2:
					color = (char - CHAR_ONE) * 96
		else:
			# blank out disallowed characters
			if char < CHAR_SPACE or char > CHAR_BETA:
				# possible dodginess here, could be modifiying the parameter inplace!
				char = CHAR_SPACE

			# change image
#			chat.SendArenaMessage(target, "Image: %d %d" % (objid, color + char - CHAR_SPACE))
			objs.Image(target, objid, color + char - CHAR_SPACE)
			objid += 1

		i += 1
		j -= 1
	else:
		# fill in remaining space with blanks
		for i in range(0, j):
			# change image
			objs.Image(target, objid, color)
			objid += 1

	# toggle
	for i in range(0, availableids):
		objs.Toggle(target, startobjectid + i, OBJ_ON)


def c_drawtext(cmd, params, p, targ):
	"""\
Module: <py> tm (aka text mapper)
Targets: none
Params: <text>
Writes <text> to everyones screen.
"""
#	chat.SendMessage(p, "writing: %s" % params)
	# force target to arena for now
	buildTextMap(params, p.arena, 50, 20)

cmd1 = add_command("t1", c_drawtext)
