extends Node
class_name DialogManager

signal line_shown(background: Texture, speaker: String, text: String, position: String, animation: String, voice_path: String)
signal choices_shown(choices: Array)  # array of { "text", "next" }
signal dialogue_triggered(action: String)
signal dialogue_ended()

var dialogue_data := {}
var current_node_id := ""
var flags := {}  # used for condition-based branching

func load_dialogue(json_path: String):
	var file = FileAccess.open(json_path, FileAccess.READ)
	var text = file.get_as_text()
	dialogue_data = JSON.parse_string(text)

	if dialogue_data.has("start"):
		current_node_id = dialogue_data["start"]
	else:
		push_error("Dialogue JSON missing 'start' node")

	process_current_node()

func process_current_node():
	if not dialogue_data.has("nodes") or not dialogue_data["nodes"].has(current_node_id):
		push_error("Invalid dialogue node: %s" % current_node_id)
		end_dialogue()
		return

	var node = dialogue_data["nodes"][current_node_id]

	# Handle conditional branching
	if node.has("conditions"):
		for condition_key in node["conditions"]:
			if not flags.get(condition_key, false):
				advance_to(node.get("else", "end"))
				return

	# Handle choices
	if node.has("choices"):
		emit_signal("choices_shown", node["choices"])
		return

	# Handle trigger (combat/shop/etc.)
	if node.has("trigger"):
		emit_signal("dialogue_triggered", node["trigger"])

	# Handle end of dialogue
	if node.get("end", false):
		end_dialogue()
		return

	# Handle regular line
	var background = node.get("background", "")
	var speaker = node.get("speaker", "")
	var text = node.get("text", "")
	var position = node.get("position", "right")
	var animation = node.get("animation", "talk")
	var voice = node.get("voice", "")

	emit_signal("line_shown", background, speaker, text, position, animation, voice)

func advance():
	var node = dialogue_data["nodes"].get(current_node_id, {})

	# If waiting on choices, do nothing
	if node.has("choices"):
		return

	var next_id = node.get("next", "end")
	advance_to(next_id)

func advance_to(next_id: String):
	current_node_id = next_id
	process_current_node()

func select_choice(index: int):
	var node = dialogue_data["nodes"].get(current_node_id, {})
	if node.has("choices") and index < node["choices"].size():
		var choice = node["choices"][index]
		if choice.has("next"):
			advance_to(choice["next"])
		else:
			end_dialogue()

func set_flag(key: String, value: bool = true):
	flags[key] = value

func end_dialogue():
	emit_signal("dialogue_ended")
