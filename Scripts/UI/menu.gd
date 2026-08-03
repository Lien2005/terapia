extends Control

@export var quit_button: Button
@export var fps_label: Label
@export var sensitivity_slider: HSlider
@export var sensitivity_spin_box: SpinBox
@export var world_environment: WorldEnvironment
@export var brightness_slider: HSlider
@export var contrast_slider: HSlider
@export var fps_custom_spinbox: SpinBox
@export var audio_h_slider: HSlider
@export var fps_check_box: CheckBox

const fps_values = {
	0: 0, 
	1: 60,
	2: 120,
	3: 144,
	4: 240
}

func _ready() -> void:
	audio_h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(
		AudioServer.get_bus_index("Master")))
	sensitivity_slider.value = Global.sensitivity * 100
	brightness_slider.value = Global.brightness
	contrast_slider.value = Global.contrast
	world_environment.environment.adjustment_brightness = Global.brightness
	world_environment.environment.adjustment_contrast = Global.contrast
	fps_label.visible = Global.display_fps
	fps_check_box.button_pressed = Global.display_fps
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		visible = not visible
		if visible == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			if(get_tree().current_scene.scene_file_path == "res://Scenes/main_menu.tscn"):
				return
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_spin_box_value_changed(value: float) -> void:
	Global.sens_changed(value / 100)
	sensitivity_slider.value = value


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Global.sens_changed(value / 100)
	sensitivity_spin_box.value = value


func _on_fps_option_button_item_selected(index: int) -> void:
	if(index == 5):
		fps_custom_spinbox.value = Engine.max_fps
		fps_custom_spinbox.show()
		return
	fps_custom_spinbox.hide()
	Engine.max_fps = fps_values[index]


func _on_brightness_slider_value_changed(value: float) -> void:
	world_environment.environment.adjustment_brightness = value
	Global.brightness = value
	
	
func _on_contrast_slider_value_changed(value: float) -> void:
	world_environment.environment.adjustment_contrast = value
	Global.contrast = value


func _on_brightness_reset_button_pressed() -> void:
	brightness_slider.value = 1


func _on_contrast_reset_button_pressed() -> void:
	contrast_slider.value = 1


func _on_fps_custom_spinbox_value_changed(value: int) -> void:
	Engine.max_fps = value


func _on_sensitivity_reset_button_pressed() -> void:
	Global.sens_changed(Global.start_sens)
	sensitivity_slider.value = Global.start_sens * 100
	sensitivity_spin_box.value = Global.start_sens * 100


func _on_audio_reset_button_pressed() -> void:
	audio_h_slider.value = 1


func _on_audio_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
	linear_to_db(value))


func _on_fps_check_box_toggled(toggled_on: bool) -> void:
	fps_label.visible = toggled_on
	Global.display_fps = toggled_on
