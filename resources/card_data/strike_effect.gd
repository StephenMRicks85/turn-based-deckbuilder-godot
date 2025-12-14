extends CardEffect

func apply(card, target):
	if target.has_method("take_damage"):
		target.take_damage(6)
