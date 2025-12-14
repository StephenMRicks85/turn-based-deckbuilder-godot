# File: gain_block_effect.gd
extends CardEffect

@export var block_amount: int = 8

func apply(source, target):
	if target.has_method("gain_block"):
		target.gain_block(block_amount)
	else:
		push_warning("Target has no method 'gain_block'")
