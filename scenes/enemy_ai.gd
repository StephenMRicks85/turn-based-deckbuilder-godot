extends Node
class_name EnemyAI

@export var intents: Array[Dictionary] = []  # Each dictionary contains info like { name, icon, description, effect_script }
@export var randomize_intents: bool = true

var current_intent: Dictionary = {}

signal intent_changed(intent: Dictionary)

func _ready():
	intents = [
		{
			"name": "Strike",
			"icon": preload("res://intent_attack.png"),
			"description": "Deals 6 damage.",
			"effect_script": preload("res://resources/card_data/strike_effect.gd")
		},
		{
			"name": "Defend",
			"icon": preload("res://armor_icon.png"),
			"description": "Gain 5 block.",
			"effect_script": preload("res://resources/card_data/charm_effect.gd")
		}
	]
	select_next_intent()

func select_next_intent():
	if intents.is_empty():
		push_error("Enemy has no defined intents!")
		return

	if randomize_intents:
		current_intent = intents[randi() % intents.size()]
	else:
		# Could use round-robin or scripted sequence
		current_intent = intents[0]  # Default to first intent

	emit_signal("intent_changed", current_intent)

func execute_intent(target: Node):
	if !current_intent.has("effect_script"):
		push_error("No effect_script assigned in current intent")
		return

	var script: Script = current_intent["effect_script"]
	var effect = script.new()
	effect.apply(self, target)

	select_next_intent()
