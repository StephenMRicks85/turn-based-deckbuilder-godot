# File: speaker_asset_registry.gd
extends Node
class_name SpeakerAssetRegistryScript

# You can also load this data from a config or external file if needed
var speaker_data := {
	"player": {
		"sprite": preload("res://resources/characters/player.tres")
	},
	"merchant": {
		"sprite": preload("res://resources/characters/merchant.tres")
	},
	"snakegirl": {
		"sprite": preload("res://resources/characters/snakegirl.tres")
	},
	"office": {
		"sprite": preload("res://resources/characters/office.tres")
	},
	"professor": {
		"sprite": preload("res://resources/characters/professor.tres")
	},
	"law_school_hallway": {
		"sprite": preload("res://resources/characters/law_school_hallway.tres")
	},
	"rival": {
		"sprite": preload("res://resources/characters/rival.tres")
	}
}

func get_sprite(speaker_name: String) -> Texture:
	if speaker_name:
		var resource = speaker_data.get(speaker_name, {}).get("sprite", null)
		return resource.get("sprite")
	return null

func get_voice(speaker_name: String) -> AudioStream:
	return speaker_data.get(speaker_name, {}).get("voice", null)

func has_speaker(speaker_name: String) -> bool:
	return speaker_data.has(speaker_name)
