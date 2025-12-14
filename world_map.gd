extends Control

@onready var encounter_container = $EncounterContainer
@onready var encounter_template = $EncounterTemplate

var encounter_options: Array[EncounterData] = []

func _ready():
	GameState.stats_updated.emit()
	load_encounters()
	spawn_encounter_nodes()

func load_encounters():
	var all_encounters : Array[EncounterData]
	all_encounters = [
		preload("res://encounters/GoblinCombat.tres"),
		preload("res://encounters/TestDialog.tres"),
		preload("res://encounters/NewDialog.tres"),
		preload("res://encounters/Intro.tres"),
		preload("res://encounters/ShopScene.tres"),
		preload("res://encounters/Rival.tres")
	]

	all_encounters.shuffle()
	encounter_options = all_encounters.slice(0, 6)

func spawn_encounter_nodes():
	var positions = [
		Vector2(200, 300), 
		Vector2(500, 320), 
		Vector2(400, 290), 
		Vector2(500, 190), 
		Vector2(150, 230), 
		Vector2(450, 420)]

	for i in range(encounter_options.size()):
		var data = encounter_options[i]
		var node = encounter_template.duplicate()
		node.visible = true
		node.position = positions[i]
		if data.icon:
			node.texture_normal = data.icon
		node.connect("pressed", Callable(self, "_on_encounter_selected").bind(data))
		encounter_container.add_child(node)
	encounter_template.queue_free()

func _on_encounter_selected(data: EncounterData):
	print("Entering encounter:", data.title)
	if data.type == "dialog":
		GameState.current_encounter_data = {
			"type": "dialogue",
			"dialogue_path": data.dialog_path
		}
	if data.scene:
		get_tree().change_scene_to_packed(data.scene)
