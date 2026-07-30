extends Control

@export var panel_container: PanelContainer
@export var quit_button: Button
@export var fps_label: Label

func _ready() -> void:
	panel_container.visible = false
	fps_label.visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if panel_container.visible == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		panel_container.visible = not panel_container.visible


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_spin_box_value_changed(value: float) -> void:
	Global.sens_changed(value / 100)

func _on_fps_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		fps_label.visible = true
	else:
		fps_label.visible = false
