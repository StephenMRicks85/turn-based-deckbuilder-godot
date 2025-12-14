extends Control
class_name ShopCardSlot

signal purchased(card: CardData)

@export var card_data: CardData
@export var price: int = 20

@onready var cost_label = $Panel/CostLabel
@onready var card_preview = $Panel/CardPreview
@onready var gray_overlay: ColorRect = $Panel/GrayOverlay
@onready var status_label: Label = $StatusLabel
const CARD_PREVIEW = preload("res://scenes/card_preview.tscn")

func _ready():
	var card_preview = CARD_PREVIEW.instantiate() as CardPreview
	card_preview.card_data = card_data
	card_preview.pass_mouse_input = true
	card_preview.refresh()
	$Panel.add_child(card_preview)
	print("card_preview type: ", card_preview.get_class())
	gray_overlay.visible = false
	status_label.visible = false
	cost_label.text = "Cost: %d" % price
	self.mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("clicking on shop card slot")
		if GameState.gold >= price:
			GameState.add_card(card_data)
			GameState.add_gold(-price)
			emit_signal("purchased", card_data)
			mark_as_purchased()

func mark_as_purchased():
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE  # disables interaction

	gray_overlay.visible = true
	status_label.visible = true
