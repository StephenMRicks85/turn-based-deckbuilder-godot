extends Control

@onready var hp_label = $HBoxContainer/HPLabel
@onready var gold_label = $HBoxContainer/GoldLabel
@onready var deck_button = $HBoxContainer/DeckButton
@onready var deck_viewer = $DeckViewer
@onready var card_grid = $DeckViewer/ScrollContainer/CardGrid
@onready var card_preview_scene := preload("res://scenes/card_preview.tscn")


func _ready():
	print(GameState.player_hp)
	GameState.connect("stats_updated", update_stats)
	update_stats()
	deck_button.pressed.connect(toggle_deck_viewer)
	set_dynamic_columns()

func set_dynamic_columns():
	var card_width = 150
	var padding = 10
	var usable_width = deck_viewer.size.x
	card_grid.columns = max(1, floor(usable_width / (card_width + padding)))

func update_stats():
	hp_label.text = "HP: %d / %d" % [GameState.player_hp, GameState.max_hp]
	gold_label.text = "Gold: %d" % GameState.gold

func toggle_deck_viewer():
	deck_viewer.visible = not deck_viewer.visible
	if deck_viewer.visible:
		refresh_deck_view()

func refresh_deck_view():
	for child in card_grid.get_children():
		child.queue_free()
	for card_data in GameState.deck:
		var preview = card_preview_scene.instantiate()
		preview.card_data = card_data
		card_grid.add_child(preview)


func _on_close_pressed() -> void:
	deck_viewer.visible = false
