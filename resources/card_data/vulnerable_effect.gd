# File: vulnerable_effect.gd
extends StatusEffect
class_name VulnerableEffect

@export var damage_multiplier: float = 1.5

func modify_damage_taken(base_damage: int) -> int:
	return int(base_damage * damage_multiplier)
