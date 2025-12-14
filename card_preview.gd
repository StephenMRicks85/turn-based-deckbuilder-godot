extends Control
class_name CardPreview

@export var card_data: CardData

@onready var name_label := $Panel/NameLabel
@onready var cost_label := $Panel/CostLabel
@onready var type_label := $Panel/TypeLabel
@onready var description_label: Label = $Panel/DescriptionLabel
@onready var card_art: Sprite2D = $Panel/CardArt
@onready var panel: Panel = $Panel
@export var pass_mouse_input: bool = true

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS if pass_mouse_input else Control.MOUSE_FILTER_STOP
	if card_data:
		refresh()

func refresh():
	if !is_inside_tree():
		await ready  # Wait until node is fully ready

	if !card_data:
		return

	if !name_label:
		push_error("CardPreview node structure is invalid: name_label is null")
		return

	name_label.text = card_data.display_name
	cost_label.text = str(card_data.energy_cost)
	type_label.text = card_data.type.capitalize()
	description_label.text = card_data.description
