extends Control

var dialogue_data = {}
var editing_state: Dictionary = {}  # Stores per-node editing data


@onready var tree = $HBoxContainer/TreeVBoxContainer/DialogueTree
@onready var id_field = $HBoxContainer/VBoxContainer/IDField
@onready var speaker_field = $HBoxContainer/VBoxContainer/SpeakerField
@onready var text_field = $HBoxContainer/VBoxContainer/TextField
@onready var choices_list = $HBoxContainer/VBoxContainer/ChoicesList

func _on_add_node_pressed():
	var new_id = "new_node"
	var suffix = 1
	
	# Ensure the ID is unique
	while dialogue_data.has(new_id):
		new_id = "new_node_%d" % suffix
		suffix += 1

	# Add default node data
	dialogue_data[new_id] = {
		"speaker": "",
		"text": "",
		"choices": []
	}

	# Optionally also initialize the editing state
	editing_state[new_id] = {
		"choices": []
	}

	# Refresh the tree and select the new node
	refresh_tree()

	# Auto-select the new node in the tree
	var root = tree.get_root()
	for i in range(root.get_child_count()):
		var item = root.get_child(i)
		if item.get_text(0) == new_id:
			tree.set_selected(item, 0)
			load_node(new_id)
			break

func _on_DeleteNodeButton_pressed():
	var id = get_current_node_id()

	if id == "":
		push_error("No node selected.")
		return

	if not dialogue_data.has(id):
		push_error("Node '%s' does not exist." % id)
		return

	# Optional: confirmation dialog
	if dialogue_data.size() <= 1:
		push_error("Cannot delete the only remaining node.")
		return

	# Remove the node from both dictionaries
	dialogue_data.erase(id)
	editing_state.erase(id)

	# Refresh tree
	refresh_tree()

	# Select the first remaining node
	var first_id = dialogue_data.keys()[0]
	load_node(first_id)

	# Update selection in the tree
	var root = tree.get_root()
	for i in range(root.get_child_count()):
		var child = root.get_child(i)
		if child.get_text(0) == first_id:
			tree.set_selected(child, 0)
			break

func _on_IDField_text_submitted(new_text):
	_on_RenameButton_pressed()

func _on_RenameButton_pressed():
	var old_id = get_current_node_id()
	var new_id = id_field.text.strip_edges()

	# Validation
	if new_id == "":
		push_error("Node ID cannot be empty.")
		id_field.text = old_id
		return

	if new_id == old_id:
		return  # Nothing to do

	if dialogue_data.has(new_id):
		push_error("A node with ID '%s' already exists!" % new_id)
		id_field.text = old_id
		return

	# Move data in dialogue_data
	dialogue_data[new_id] = dialogue_data[old_id]
	dialogue_data.erase(old_id)

	# Move editing state
	if editing_state.has(old_id):
		editing_state[new_id] = editing_state[old_id]
		editing_state.erase(old_id)

	# Refresh tree and select new ID
	refresh_tree()
	var root = tree.get_root()
	for i in range(root.get_child_count()):
		var child = root.get_child(i)
		if child.get_text(0) == new_id:
			tree.set_selected(child, 0)
			load_node(new_id)
			break

# Helper functions for per-node editing state
func get_current_node_id() -> String:
	return id_field.text.strip_edges()

func get_current_choices() -> Array:
	var id = get_current_node_id()
	if not editing_state.has(id):
		editing_state[id] = {}
	if not editing_state[id].has("choices"):
		editing_state[id]["choices"] = []
	return editing_state[id]["choices"]

func set_current_choices(choices: Array):
	var id = get_current_node_id()
	if not editing_state.has(id):
		editing_state[id] = {}
	editing_state[id]["choices"] = choices

func set_selected_choice(index: int):
	var id = get_current_node_id()
	if not editing_state.has(id):
		editing_state[id] = {}
	editing_state[id]["selected_choice_index"] = index

func refresh_choice_list():
	choices_list.clear()
	for c in get_current_choices():
		var label = "%s → %s" % [c.get("text", ""), c.get("next", "")]
		choices_list.add_item(label)

func _on_add_choice_pressed():
	var choice = {
		"text": "New Choice",
		"next": "",
		"condition": "",
		"effect": ""
	}
	var choices = get_current_choices()
	choices.append(choice)
	refresh_choice_list()

func _on_edit_choice_pressed():
	var selected = choices_list.get_selected_items()
	if selected.is_empty():
		print("⚠️ No choice selected.")
		return

	var selected_choice_index = selected[0]
	set_selected_choice(selected_choice_index)
	var choice = get_current_choices()[selected_choice_index]
	
	$ChoiceModal/MarginContainer/ChoiceForm/ChoiceTextField.text = choice.get("text", "")
	$ChoiceModal/MarginContainer/ChoiceForm/NextIDTextField.text = choice.get("next", "")
	$ChoiceModal/MarginContainer/ChoiceForm/ConditionTextField.text = choice.get("condition", "")
	$ChoiceModal/MarginContainer/ChoiceForm/EffectTextField.text = choice.get("effect", "")
	$ChoiceModal.visible = true

func _on_save_choice_pressed():
	var choice = {
		"text": $ChoiceModal/MarginContainer/ChoiceForm/ChoiceTextField.text,
		"next": $ChoiceModal/MarginContainer/ChoiceForm/NextIDTextField.text,
		"condition": $ChoiceModal/MarginContainer/ChoiceForm/ConditionTextField.text,
		"effect": $ChoiceModal/MarginContainer/ChoiceForm/EffectTextField.text,
	}
	var choices = get_current_choices()
	var id = get_current_node_id()
	var index = editing_state.get(id, {}).get("selected_choice_index", -1)

	if index >= 0 and index < choices.size():
		choices[index] = choice
	refresh_choice_list()
	$ChoiceModal.visible = false

func _on_remove_choice_pressed():
	var selected = choices_list.get_selected_items()
	if selected.is_empty():
		print("⚠️ No choice selected to remove.")
		return

	var index = selected[0]
	var choices = get_current_choices()
	if index >= 0 and index < choices.size():
		choices.remove_at(index)
	refresh_choice_list()

func save_current_node():
	var id = id_field.text
	dialogue_data[id] = {
		"speaker": speaker_field.text,
		"text": text_field.text,
		"choices": get_current_choices().duplicate(true)
	}

func _ready():
	GlobalHUD.visible = false
	tree.item_selected.connect(_on_node_selected)
	$HBoxContainer/VBoxContainer/SaveButton.pressed.connect(_on_save)
	$HBoxContainer/VBoxContainer/LoadButton.pressed.connect(_on_load)

func _on_node_selected():
	var id = tree.get_selected().get_text(0)
	load_node(id)

func load_node(id: String):
	var node = dialogue_data.get(id, {})
	id_field.text = id
	speaker_field.text = node.get("speaker", "")
	text_field.text = node.get("text", "")

	# Load or create editing state
	if not editing_state.has(id):
		editing_state[id] = {
			"choices": []
		}

	# Only populate choices if they haven't been loaded already
	if editing_state[id]["choices"].is_empty() and node.has("choices"):
		for c in node["choices"]:
			editing_state[id]["choices"].append(c.duplicate(true))

	refresh_choice_list()

func _on_save():
	save_current_node()
	var file = FileAccess.open("user://dialogue.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(dialogue_data, "\t"))
	file.close()

func _on_load():
	var file = FileAccess.open("user://dialogue.json", FileAccess.READ)
	dialogue_data = JSON.parse_string(file.get_as_text())
	refresh_tree()

func refresh_tree():
	tree.clear()
	var root = tree.create_item()
	for id in dialogue_data.keys():
		var item = tree.create_item(root)
		item.set_text(0, id)
