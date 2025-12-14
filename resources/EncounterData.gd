extends Resource
class_name EncounterData

@export var title: String
@export var type: String # e.g. "combat", "shop", "event"
@export var dialog_path: String
@export var scene: PackedScene
@export var icon: Texture2D
@export var is_boss: bool = false
