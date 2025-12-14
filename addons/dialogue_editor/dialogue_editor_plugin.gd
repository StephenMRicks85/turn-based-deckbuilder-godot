@tool
extends EditorPlugin

var editor

func _enter_tree():
	editor = preload("res://addons/dialogue_editor/DialogueEditor.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, editor)
	add_tool_menu_item("Dialogue Editor", self, "_on_menu_pressed")

func _exit_tree():
	remove_control_from_docks(editor)
	remove_tool_menu_item("Dialogue Editor")

func _on_menu_pressed():
	editor.visible = true
