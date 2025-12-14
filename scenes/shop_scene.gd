extends Control

@onready var shop_grid := $ShopGrid
@onready var leave_button := $LeaveButton
@onready var shop_card_slot_scene := preload("res://scenes/shop_card_slot.tscn")
@onready var card_removal_modal_scene := preload("res://scenes/card_removal.tscn")
@onready var card_removal_button_scene := preload("res://scenes/removebutton.tscn")

var card_removal_modal: Node
@onready var removal_button: RemoveButtonSlot

func _ready():
	leave_button.pressed.connect(_on_leave_pressed)

	# Instantiate and add the removal modal to the scene tree
	card_removal_modal = card_removal_modal_scene.instantiate()
	add_child(card_removal_modal)
	card_removal_modal.visible = false

	# Add card slots to the shop grid
	var shop_cards = CardPool.get_random_shop_cards()
	for card_data in shop_cards:
		var slot = shop_card_slot_scene.instantiate()
		slot.card_data = card_data
		slot.price = randi_range(10, 40)
		slot.purchased.connect(_on_card_purchased)
		shop_grid.add_child(slot)

	# Add the removal button (styled like shop slots)
	removal_button = card_removal_button_scene.instantiate()
	shop_grid.add_child(removal_button)

	# Wire up its internal button to trigger the removal modal
	var inner_button = removal_button.get_node_or_null("Button")
	if inner_button:
		inner_button.pressed.connect(_on_remove_card_pressed)
	else:
		push_error("❌ RemoveButton scene is missing a 'Button' node!")

func _on_remove_card_pressed():
	card_removal_modal.open(GameState.deck, 50, func(card):
		print("🗑️ Removed card:", card.display_name)
		if removal_button:
			removal_button.disable_button()
	)


func _on_card_purchased(card_data):
	print("Purchased:", card_data.display_name)

func _on_leave_pressed():
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")
