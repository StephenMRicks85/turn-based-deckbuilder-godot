extends CardEffect

func apply(card, target):
	var battle = card.get_tree().current_scene
	battle.draw_cards(2)
