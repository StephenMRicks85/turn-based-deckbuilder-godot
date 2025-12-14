extends Panel
class_name CardRemovalModal

signal card_removed(card_data: CardData)

@export var card_preview_scene: PackedScene
@onready var grid = $CardGrid
@onready var cancel_button = $CancelButton

var removal_cost: int = 50
var on_card_removed_callback: Callable = func(_card): pass  # Optional

func _ready():
	cancel_button.pressed.connect(hide)

func open(deck: Array, cost: int = 50, callback: Callable = Callable()):
	removal_cost = cost
	on_card_removed_callback = callback if callback else func(_card): pass
	visible = true
	populate(deck)

func populate(deck: Array):
	grid.get_children().map(func(child): child.queue_free())

	for card_data in deck:
		var preview = card_preview_scene.instantiate()
		preview.card_data = card_data
		preview.refresh()

		preview.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				if GameState.gold >= removal_cost:
					GameState.remove_card(card_data)
					GameState.add_gold(-removal_cost)
					card_removed.emit(card_data)
					GameState.stats_updated
					on_card_removed_callback.call(card_data)
					hide()
				else:
					print("❌ Not enough gold to remove card")
		)

		grid.add_child(preview)
