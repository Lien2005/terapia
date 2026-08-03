extends Node3D

@export var menu: Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/night.tscn")

func _on_settings_button_pressed() -> void:
	menu.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()
