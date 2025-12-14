extends Area2D
class_name EnemyStats


@export var max_hp := 20
var current_hp := max_hp
@onready var enemy_ai: EnemyAI = $"../EnemyAI"


signal health_changed(current: int, max: int)

func _ready():
	add_to_group("enemies")
	update_label()
	#await get_tree().create_timer(2.0).timeout 
	#take_damage(5)

func perform_action(target):
	print("💢 Enemy attacks!")
	if enemy_ai.current_intent:
		enemy_ai.execute_intent(target)
	#if get_tree().current_scene.has_method("receive_damage"):
		#get_tree().current_scene.receive_damage(2)

func take_damage(amount: int):
	for effect in status_effects:
		if effect.has_method("modify_damage_taken"):
			amount = effect.modify_damage_taken(amount)
	current_hp -= amount
	update_label()
	health_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		get_parent().enemy_defeated.emit()
		get_parent().queue_free()

func update_label():
	%Label.text = "HP: %d" % current_hp

var status_effects: Array[StatusEffect] = []

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
