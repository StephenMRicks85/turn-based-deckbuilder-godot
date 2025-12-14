class_name RemoveButtonSlot
extends Control

@onready var button: Button = $Button
@onready var gray_overlay: ColorRect = $Button/GrayOverlay
@onready var status_label: Label = $StatusLabel

func _ready():
	gray_overlay.visible = false
	status_label.visible = false

func disable_button():
	button.disabled = true
	gray_overlay.visible = true
	status_label.visible = true
