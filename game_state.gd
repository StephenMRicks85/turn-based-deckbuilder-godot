extends Node
class_name GameStateScript
	
signal stats_updated()

var player_hp: int = 40
var max_hp: int = 40
var gold: int = 0
var deck: Array[CardData] = []
var current_encounter_data: Dictionary = {}

func add_card(card: CardData):
	deck.append(card)
	stats_updated.emit()

func remove_card(card_data: CardData) -> void:
	# Removes the *first* matching instance of the card from the player's deck
	if card_data in deck:
		deck.erase(card_data)
		print("🗑️ Removed card:", card_data.display_name)
	else:
		print("⚠️ Tried to remove card not in deck:", card_data.display_name)


func take_damage(amount: int):
	player_hp = max(player_hp - amount, 0)
	stats_updated.emit()

func heal(amount: int):
	player_hp = min(player_hp + amount, max_hp)
	stats_updated.emit()

func add_gold(amount: int):
	gold += amount
	stats_updated.emit()

const SAVE_PATH := "user://savegame.json"

func save():
	var data = {
		"scene": get_tree().current_scene.scene_file_path,
		"player_hp": player_hp,
		"max_hp": max_hp,
		"gold": gold,
		"deck": deck.map(func(card): return card.resource_path)
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("✅ Game saved to %s" % SAVE_PATH)

func load():
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠️ No save file found.")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	var data = JSON.parse_string(text)

	player_hp = data.get("player_hp", 40)
	max_hp = data.get("max_hp", 40)
	gold = data.get("gold", 0)

	deck = _load_card_array(data.get("deck", []))

	# Load the saved scene
	var scene_path = data.get("scene", "")
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		print("⚠️ Scene path missing in save data.")

	return true

func _load_card_array(paths: Array) -> Array[CardData]:
	var result: Array[CardData] = []
	for path in paths:
		var card = load(path)
		if card:
			result.append(card)
	return result
