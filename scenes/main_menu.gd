extends Control

@onready var new_game_button = $Panel/VBoxContainer/NewGameButton
@onready var coitinue_button = $Panel/VBoxContainer/Continue
@onready var quit_button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	GlobalHUD.visible = false

func _on_new_game_pressed():
	GlobalHUD.visible = true
	# Reset game state (optional)
	GameState.player_hp = GameState.max_hp
	GameState.gold = 50
	GameState.deck = []  # Or populate with starter cards
	var card_resource = preload("res://resources/card_data/facts.tres") # test card
	for i in 5:
		GameState.deck.append(card_resource)
	card_resource = preload("res://resources/card_data/fortify.tres") # test card
	for i in 4:
		GameState.deck.append(card_resource)
	card_resource = preload("res://resources/card_data/charm.tres")
	GameState.deck.append(card_resource)
	GameState.deck.shuffle()

	# Start at world map or first encounter
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")

func _on_continue_pressed():
	GlobalHUD.visible = true
	var success = GameState.load()
	GameState.stats_updated.emit()
	if not success:
		print("⚠️ Failed to load save")

func _on_quit_pressed():
	get_tree().quit()
