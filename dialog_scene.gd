extends Control

@onready var dialog_manager = $DialogManager
@onready var character_left = $CharacterLeft/Sprite2D
@onready var character_right = $CharacterRight/Sprite2D
@onready var speaker_label = $DialogUI/Panel/Speaker
@onready var text_label = $DialogUI/Panel/DialogText
@onready var choices_container = $DialogUI/Panel/ChoicesContainer
@onready var continue_button = $DialogUI/Panel/ContinueButton
@onready var voice_player = $AudioStreamPlayer
@onready var encounter_data  := {}
@onready var background_texture: TextureRect = $Background

func _ready():
	GameState.save()
	dialog_manager.connect("line_shown", _on_line_shown)
	dialog_manager.connect("choices_shown", _on_choices_shown)
	dialog_manager.connect("dialogue_triggered", _on_dialogue_triggered)
	dialog_manager.connect("dialogue_ended", _on_dialogue_ended)

	choices_container.visible = false
	continue_button.pressed.connect(_on_continue_pressed)

	# Start sample dialogue
	dialog_manager.load_dialogue(GameState.current_encounter_data.dialogue_path)

func _on_line_shown(background, speaker, text, position, animation, voice_path):
	if background:
		background_texture.texture = SpeakerAssetRegistry.get_sprite(background)
	speaker_label.text = speaker
	text_label.text = text
	choices_container.visible = false
	continue_button.visible = true

	# Load sprite from SpeakerAssetRegistry
	var sprite = SpeakerAssetRegistry.get_sprite(speaker)
	if sprite:
		if position == "left":
			character_left.texture = sprite
		else:
			character_right.texture = sprite
	else:
		print("⚠️ No sprite found for speaker:", speaker)

	# Animate speaker modulate (dim the non-speaker)
	if position == "left":
		character_left.modulate = Color.WHITE
		character_right.modulate = Color.GRAY
	else:
		character_left.modulate = Color.GRAY
		character_right.modulate = Color.WHITE

	# Load voice from SpeakerAssetRegistry, override if voice_path is provided
	var voice_stream: AudioStream = null
	if voice_path != "":
		voice_stream = load(voice_path)
	else:
		voice_stream = SpeakerAssetRegistry.get_voice(speaker)

	if voice_stream:
		voice_player.stream = voice_stream
		voice_player.play()

func _on_continue_pressed():
	dialog_manager.advance()

func _on_choices_shown(choices):
	choices_container.visible = true
	continue_button.visible = false
	for child in choices_container.get_children():
		child.queue_free()

	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i]["text"]
		btn.pressed.connect(_on_choice_selected.bind(i))
		choices_container.add_child(btn)

func _on_choice_selected(index):
	dialog_manager.select_choice(index)

func _on_dialogue_triggered(trigger):
	match trigger:
		"combat":
			print("⚔️ Start combat here")
			get_tree().change_scene_to_file("res://scenes/combat_scene.tscn")
		"shop":
			print("🛒 Open shop here")

func _on_dialogue_ended():
	print("✅ Dialogue complete")
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")
