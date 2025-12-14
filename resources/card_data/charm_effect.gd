extends CardEffect

func apply(card, target):
	var vulnerable = preload("res://resources/card_data/vulnerable_effect.tres").duplicate()
	target.apply_status(vulnerable)
