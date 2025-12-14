# ImproviseModal.gd
extends Control

signal card_selected(card: CardData)

@onready var card_grid = $Panel/CardGrid
@export var card_preview_scene: PackedScene

func open(cards: Array[CardData]):
	visible = true
	card_grid.get_children().map(func(c): c.queue_free())

	for card_data in cards:
		var preview = card_preview_scene.instantiate()
		preview.card_data = card_data
		preview.refresh()
		preview.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				card_selected.emit(card_data)
				visible = false
		)
		card_grid.add_child(preview)
