extends Node
class_name PlayerActor

var status_effects: Array[StatusEffect] = []
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.add_to_group("player")

func take_damage(amount: int):
	var actual_damage = max(amount - block, 0)
	block = max(block - amount, 0)
	%BlockLabel.text = "🛡️: " + str(block)
	GameState.take_damage(actual_damage)
	print("🧍 Player takes ", actual_damage, " damage! (HP now: ", GameState.player_hp, "/", GameState.max_hp, ")")
	GameState.stats_updated.emit()
	# Optionally trigger animation or update HUD

var block := 0

func gain_block(amount: int):
	block += amount
	%BlockLabel.text = "🛡️: " + str(block)
	print("🛡️ Player gains ", amount, " block! (Total block: ", block, ")")

func apply_status(effect: StatusEffect):
	%StatusEffectsLabel.text = effect.name
	for existing in status_effects:
		if existing.id == effect.id:
			existing.refresh_or_stack(effect)
			return
	status_effects.append(effect)

func on_turn_start():
	for effect in status_effects:
		effect.on_turn_start(self)

func on_turn_end():
	for effect in status_effects:
		effect.on_turn_end(self)
	status_effects = status_effects.filter(func(e): return not e.should_expire())
	for effect in status_effects:
		%StatusEffectsLabel.text.append(effect.name + " ")
	if status_effects.size() == 0:
		%StatusEffectsLabel.text = ""
