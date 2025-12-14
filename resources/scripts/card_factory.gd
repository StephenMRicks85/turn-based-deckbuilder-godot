# File: res://resources/scripts/card_factory.gd
extends Node
class_name CardFactory

@export var card_scene: PackedScene = preload("res://scenes/Card.tscn")

# Creates a Card node instance from a CardData resource
func create_card(card_data: CardData) -> Card:
	if not card_scene:
		push_error("CardFactory: card_scene is not assigned.")
		return null

	var card_instance: Card = card_scene.instantiate()
	card_instance.card_data = card_data
	card_instance.refresh_card()
	return card_instance
