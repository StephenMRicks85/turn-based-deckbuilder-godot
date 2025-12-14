# File: PlayerHand.gd
extends Control
class_name PlayerHand

@onready var container := $CardContainer

func add_card(card: Card) -> void:
	if container:
		container.add_child(card)

func get_hand_cards() -> Array:
	return get_node("CardContainer").get_children()

func clear_hand():
	for card in container.get_children():
		card.queue_free()
