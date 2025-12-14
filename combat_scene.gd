# File: CombatScene.gd
extends Node2D

@onready var player_hand: PlayerHand = $PlayerHand
@onready var enemies = $Enemies
@onready var energy_label := $EnergyLabel  # Adjust path as needed
@onready var victory_modal: Panel = $VictoryModal
@onready var continue_button: Button = $VictoryModal/VBoxContainer/Continue
@onready var draw_button := $DrawPile
@onready var discard_button := $DiscardPile
@onready var draw_modal := $DrawPileModal
@onready var discard_modal := $DiscardPileModal
@onready var draw_grid := $DrawPileModal/ScrollContainer/DrawCardGrid
@onready var discard_grid := $DiscardPileModal/ScrollContainer/DiscardCardGrid
@onready var card_preview_scene := preload("res://scenes/card_preview.tscn")
@onready var improvise_modal: Control = $ImproviseModal
@onready var temporary_card_pool: TemporaryCardPool = $TemporaryCardPool
@onready var player_actor: PlayerActor = $PlayerActor


var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []
var max_energy := 3
var current_energy := max_energy
enum TurnState {
	PLAYER_TURN,
	ENEMY_TURN,
	WAITING
}

var turn_state: TurnState = TurnState.WAITING
@onready var end_turn_button: Button = $UI/EndTurnButton
@onready var card_factory = preload("res://resources/scripts/card_factory.gd").new()

func add_card_to_hand(card_data: CardData):
	var new_card = card_factory.create_card(card_data)
	if new_card:
		$PlayerHand.add_child(new_card)

func trigger_improvise():
	$PlayerHand.hide()
	var choices = temporary_card_pool.get_random_choices()
	improvise_modal.open(choices)
	improvise_modal.card_selected.connect(_on_temp_card_chosen)

func _on_temp_card_chosen(card_data: CardData):
	$PlayerHand.show()
	var card_instance = card_factory.create_card(card_data)
	$PlayerHand.add_card(card_instance)
	sort_hand()
	#GameState.temporary_battle_cards.append(card_data)


func show_victory_modal():
	turn_state = TurnState.WAITING
	victory_modal.visible = true
	continue_button.grab_focus()
	GameState.add_gold(20)

var active_enemies: Array[Node] = []

func spawn_enemy(enemy_scene: PackedScene, position: Vector2):
	var enemy = enemy_scene.instantiate()
	$Enemies.add_child(enemy)
	enemy.position = position
	var ok = enemy.connect("enemy_defeated", self._on_enemy_defeated)
	active_enemies.append(enemy)

func _on_enemy_defeated():
	await get_tree().process_frame  # Wait for the enemy to actually be removed
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			return  # Still one alive
	show_victory_modal()

func _on_end_turn_button_pressed():
	if turn_state == TurnState.PLAYER_TURN:
		end_player_turn()

func receive_damage(amount: int):
	GameState.take_damage(2)
	print("🧍 Player takes ", amount, " damage!")

func start_player_turn():
	turn_state = TurnState.PLAYER_TURN
	player_actor.on_turn_start()
	current_energy = max_energy
	update_energy_display()
	draw_cards(5)
	print("▶️ Player Turn Started")

func try_play_card(cost: int) -> bool:
	if current_energy >= cost:
		current_energy -= cost
		update_energy_display()
		return true
	else:
		return false

func on_card_played(card: Card):
	discard_pile.append(card.card_data)
	card.queue_free()

func update_energy_display():
	energy_label.text = "Energy: %d / %d" % [current_energy, max_energy]

func _ready():
	GameState.save()
	victory_modal.visible = false
	spawn_enemy(preload("res://scenes/enemy.tscn"), Vector2(0.0, 0.0))
	draw_button.pressed.connect(_on_draw_pile_pressed)
	discard_button.pressed.connect(_on_discard_pile_pressed)

	# Hide modals on load
	draw_modal.visible = false
	discard_modal.visible = false
	load_deck()
	start_combat()

func start_combat():
	start_player_turn()

func end_player_turn():
	print("🔁 Ending Player Turn")
	player_actor.on_turn_end()
	turn_state = TurnState.WAITING
	discard_hand()
	await get_tree().create_timer(0.5).timeout  # short delay before enemy turn
	turn_state = TurnState.ENEMY_TURN
	start_enemy_turn()

func print_discard_pile():
	print("🗃 Discard pile:")
	for card in discard_pile:
		print("- ", card.display_name)

func start_enemy_turn():
	print("😈 Enemy Turn Started")
	await get_tree().create_timer(0.5).timeout  # small delay before actions

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("perform_action"):
			enemy.perform_action(player_actor)
			await get_tree().create_timer(0.5).timeout  # delay between enemies

	end_enemy_turn()

func end_enemy_turn():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.on_turn_end()
	print("🔄 Back to Player Turn")
	start_player_turn()

func load_deck():
	for card in GameState.deck:
		draw_pile.append(card)

func draw_cards(amount: int):
	var card_scene = preload("res://scenes/card.tscn")
	for i in amount:
		if draw_pile.is_empty():
			reshuffle_discard()
		if draw_pile.is_empty(): return
		var card_data = draw_pile.pop_back()
		var card_instance = card_scene.instantiate() as Card
		card_instance.card_data = card_data
		card_instance.global_position = player_hand.global_position + Vector2(i * 175, 0)
		player_hand.add_card(card_instance)
		card_instance.connect("card_dropped_on_target", _on_card_dropped_on_target)

func sort_hand():
	var i = 0
	for card in player_hand.get_hand_cards():
		card.global_position = player_hand.global_position + Vector2(i * 175, 0)
		i += 1

func discard_hand():
	for card in player_hand.get_hand_cards():
		discard_pile.append(card.card_data)
		card.queue_free()

func reshuffle_discard():
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()

func _on_card_dropped_on_target():
	pass

func cleanup_battle():
	for card_data in GameState.temporary_battle_cards:
		GameState.remove_card(card_data)
	GameState.temporary_battle_cards.clear()

func _on_button_pressed() -> void:
	print_discard_pile()

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")


func _on_draw_pile_pressed() -> void:
	draw_modal.visible = !draw_modal.visible
	if draw_modal.visible:
		refresh_card_list(draw_grid, draw_pile)


func _on_discard_pile_pressed() -> void:
	discard_modal.visible = !discard_modal.visible
	if discard_modal.visible:
		refresh_card_list(discard_grid, discard_pile)

func refresh_card_list(grid: GridContainer, pile: Array):
	for child in grid.get_children():
		child.queue_free()

	for card_data in pile:
		var preview = card_preview_scene.instantiate()
		preview.card_data = card_data
		grid.add_child(preview)


func _on_close_pressed() -> void:
	discard_modal.visible = false
	draw_modal.visible = false
