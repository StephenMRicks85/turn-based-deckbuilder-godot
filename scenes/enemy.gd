extends Node2D

signal enemy_defeated
@onready var area_2d: EnemyStats = $Area2D

func take_damage(amount: int):
	area_2d.take_damage(amount)
