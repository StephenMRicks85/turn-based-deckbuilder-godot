extends Resource
class_name StatusEffect

@export var id: String
@export var name: String
@export var description: String
@export var icon: Texture
@export var duration: int = 1
@export var stacks: int = 1

func apply_effect(target):
	pass # e.g., apply a passive stat boost

func on_turn_start(target):
	pass # e.g., poison damage

func on_turn_end(target):
	duration -= 1

func should_expire() -> bool:
	return duration <= 0

func refresh_or_stack(new_effect: StatusEffect):
	if new_effect.id == id:
		duration += new_effect.duration
