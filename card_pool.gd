extends Node
class_name CardPoolScript

var common_cards = [
	#preload("res://resources/card_data/strike.tres"),
	#preload("res://resources/card_data/defend.tres")
	preload("res://resources/card_data/facts.tres"),
	preload("res://resources/card_data/fortify.tres"),
	preload("res://resources/card_data/appeal_to_reason.tres"),
	preload("res://resources/card_data/consider.tres"),
	preload("res://resources/card_data/improvise.tres"),
	preload("res://resources/card_data/rebuttal.tres")
]
var rare_cards = [
	#preload("res://resources/card_data/powerstrike.tres")
]

func get_random_shop_cards(count: int = 3) -> Array:
	var pool = []
	pool.append_array(common_cards)
	pool.append_array(rare_cards)
	pool.shuffle()
	return pool.slice(0, count)
