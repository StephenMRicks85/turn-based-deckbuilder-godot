# File: Card.gd
extends Panel
class_name Card

@export var card_data: CardData
@onready var card_area: Area2D = $CardArea
@onready var card_name: Label = $CardArea/CardName


signal card_dropped_on_target(card: Card, target: Node)

var dragging := false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO
var current_target: Node = null
var overlapping_enemies := []
var original_scale := Vector2.ONE
var is_targeteing_player := false

func _ready():
	add_to_group("card")
	original_position = global_position
	card_area.input_pickable = true
	card_area.connect("area_entered", _on_area_entered)
	card_area.connect("area_exited", _on_area_exited)
	card_area.connect("mouse_entered", _on_mouse_entered)
	card_area.connect("mouse_exited", _on_mouse_exited)
	modulate = match_color(card_data.rarity)
	card_name.text = card_data.display_name
	
	original_scale = scale
	$Border.visible = false


func _input(event):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset	

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			# Center the drag on the card
			drag_offset = -size * 0.5
			move_to_front()
		else:
			if dragging:
				handle_card_drop()
			dragging = false

func handle_card_drop():
	
	var combat_scene = get_tree().current_scene
	if overlapping_enemies.size() > 0:
		var enemy = overlapping_enemies[0]  # You can allow multi-target later
		if combat_scene.has_method("try_play_card"):
			if combat_scene.try_play_card(card_data.energy_cost):
				apply_effect(enemy)
				if combat_scene.has_method("on_card_played"):
					combat_scene.on_card_played(self)
			else:
				print("❌ Not enough energy to play this card")
				return_to_hand()
	elif card_data.target == "self" and is_targeteing_player:
		var player = combat_scene.get_node("%PlayerActor")
		if combat_scene.try_play_card(card_data.energy_cost):
			apply_effect(player)
			if combat_scene.has_method("on_card_played"):
				combat_scene.on_card_played(self)
		else:
			print("❌ Not enough energy to play this card")
			return_to_hand()
	else:
		# Missed target — discard or return to hand
		return_to_hand()

func refresh_card():
	if not card_data:
		return
	$CardArea/CardName.text = card_data.display_name
	# Update cost, type, description, etc., if applicable


func apply_effect(enemy):
	if card_data.type == "Attack":
		if enemy.has_method("take_damage"):
			#enemy.take_damage(card_data.damage_amount)
			card_data.effect.apply(self, enemy)
	if card_data.type == "Skill":
		card_data.effect.apply(self, enemy)
	if card_data.id == "improvise":
		if get_tree().current_scene.has_method("trigger_improvise"):
			get_tree().current_scene.trigger_improvise()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		overlapping_enemies.append(area)
	if area.is_in_group("player"):
		is_targeteing_player = true

func _on_area_exited(area):
	if area.is_in_group("enemies"):
		overlapping_enemies.erase(area)
	if area.is_in_group("player"):
		is_targeteing_player = false

func _on_mouse_entered():
	scale = original_scale * 1.2
	z_index += 1
	$Border.visible = true

func _on_mouse_exited():
	scale = original_scale
	z_index -= 1
	$Border.visible = false

func return_to_hand():
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", original_position, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func match_color(rarity: String) -> Color:
	match rarity:
		"Rare": return Color.hex(0xFFD700)  # Gold
		"Common": return Color.WHITE
		_: return Color.GRAY
