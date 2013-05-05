#BlackJack by Chambahs
#1-25-05

from asss import *

chat = get_interface(I_CHAT)
stats = get_interface(I_STATS)



def c_deal(cmd, params, p, targ):
	points = stats.GetStat(p, STAT_KILL_POINTS, INTERVAL_RESET)+ stats.GetStat(p, STAT_FLAG_POINTS, INTERVAL_RESET)
	chat.SendMessage(p, "1000 Points have been betted. - Points Left: %d" % points -1000)
	stats.GetStat(p, % points - 1000)
	A = 11
	K = 10
	Q = 10
	J = 10
	A+J = 21
	random_card1 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	random_card2 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	random_card3 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	random_card4 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	card_total = random_card1 + random_card2
	card_total2 = random_card3 + random_card4
	chat.SendMessage(p, "Your cards are:" random_card1, random.card2 " (Total = " card_total1 ")"
	chat.SendMessage(p, "Dealers cards are:" random.card3, random.card4 " (Total = " card_total2 ")"
	if card_total < 21:
		chat.SendMessage(p, "Hit or stand? (Type ?hit or ?stand)")
	else:
		chat.SendMessage(p, "You got 21!")
		stats.GetStat(p. % points +2500)
	if random_card1 + random_card2 == A+J:
		chat.SendMessage(p, "BLACKJACK!")
		stats.GetStat(p, % points + 3000)
	

def c_hit(cmd, params, p, targ):
	hit_card1 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	hit_card2 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	hit_card3 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	hit_card4 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	hit_card5 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	hit_card6 = random(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"])
	card_total3 = card_total + hit_card1
	card_total4 = card_total + hit_card1 + hit_card2
	card_total5 = card_total + hit_card1 + hit_card2 + hit_card3
	deal_total1 = card_total2 + hit_card4
	deal_total2 = card_total2 + hit_card4 + hit_card5
	deal_total3 = card_total2 + hit_card4 + hit_card5 + hit_card6
	chat.SendMessage(p, "Hit!")
	chat.SendMessage(p, "Current Cards = " random_card1, random_card2, hit_card1 " (Total = " random_card1+random_card2+hit_card1 ")"
	if card_total3 >= 22:
		chat.SendMessage(p, "Bust! You lose, Please play again")
	else:
		chat.SendMessage(p, "Hit again or stand? (Type ?hit2 or ?stand)")

def c_hit2(cmd, params, p, targ):
	chat.SendMessage(p, "Hit!")
	chat.SendMessage(p, "Current Cards = " random_card1, random_card2, hit_card1, hit_card2 " (Total = " random_card1+random_card2+hit_card1+hit_card2 ")"
	if card_total4 >= 22:
		chat.SendMessage(p, "Bust! You lose, Please play again")
	else:
		chat.SendMessage(p, "Hit again or stand? (Type ?hit3 or ?stand)")

def C_hit3(cmd, params, p, targ):
	chat.SendMessage(p, "Hit!")
	chat.SendMessage(p, "Current Cards = " random_card1, random_card2, hit_card1, hit_card2, hit_card3 " (Total = " random_card1+random_card2+hit_card1+hit_card2+hit_card3 ")"
	if card_total5 >= 22:
		chat.SendMessage(p, "Bust! You lose, Please play Again")
	else:
		chat.SendMessage(p, "5 Card Stand! You Win!!")
		stats.GetStat(p, %points + 2000)

def c_stand(cmd, params, p, targ):
	chat.SendMessage(p, "Stay it is.")
	if card_total2 <= 17:
		chat.SendMessage(p, "The Dealer Hits! - Current Cards = " random_card2, random_card3, hit_card4 " (Total = " deal_total1 ")"
		if deal_total1 <= 17:
			chat.SendMessage(p, "The Dealer Hits Again! - Current Cards = " random_card2, random_card3, hit_card4, hit_card5 " (Total = " deal_total2 ")"
			if deal_total2 <= 17:
				chat.SendMessage(p, "The Dealer Hits Again! - Current Cards = " random_card2, random_card3, hit_card4, hit_card5, hit_card6 " (Total = " deal_total3 ")"
				if deal_total3 <= 21:
					chat.SendMessage(p, "Dealer has 5 Card Stand! You lose, Please Play Again")
				else:
					chat.SendMessage(p, "Dealer is Bust! You Win!")
			elif deal_total2 <= 18 and >= 21:
				chat.SendMessage(p, "The dealer stands with" deal_total2)
			elif deal_total2 == 21:
				chat.SendMessage(p, "Dealer has 21!")
			elif deal_total1 == A+J:
				chat.SendMessage(p, "Dealer has Blackjack!")
			else:
				chat.SendMessage(p, "Dealer is Bust! You Win!")
		elif deal_total1 <= 18 and >= 21:
			chat.SendMessage(p, "The dealer stands with" deal_total1)
		elif deal_total1 == 21:
			chat.SendMessage(p, "Dealer has 21!")
		elif deal_total1 == A+J:
			chat.SendMessage(p, "Dealer has Blackjack!")
		else:
			chat.SendMessage(p, "Dealer is Bust! You Win!")
	elif card_total2 <= 18 and >= 21:
		chat.SendMessage(p, "The dealer stands with" card_total2)
	elif card_total2 == 21:
		chat.SendMessage(p, "Dealer has 21!")
	elif card_total2 == A+J:
		chat.SendMessage(p, "Dealer has Blackjack!")
	else:
		chat.SendMessage(p, "Dealer is Bust! You Win!")