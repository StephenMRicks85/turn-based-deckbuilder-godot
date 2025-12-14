extends CanvasLayer
class_name PlayerHUDController

@onready var hud := preload("res://scenes/player_hud.tscn").instantiate()

func _ready():
	add_child(hud)
	set_layer(10)  # On top of main game scenes
