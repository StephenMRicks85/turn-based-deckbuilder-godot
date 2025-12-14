# File: TemporaryCardPool.gd
extends Node
class_name TemporaryCardPool

var improvise_cards: Array[CardData] = [
	preload("res://resources/card_data/appeal_to_reason.tres"),
	preload("res://resources/card_data/charm.tres"),
	preload("res://resources/card_data/false_dilemma.tres"),
	preload("res://resources/card_data/legal_precedent.tres"),
	preload("res://resources/card_data/rebuttal.tres")
]

func get_random_choices(count := 3) -> Array[CardData]:
	var copy = improvise_cards.duplicate()
	copy.shuffle()
	return copy.slice(0, count)
