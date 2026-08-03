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
@export var screen_option_button: OptionButton
@export var fps_option_button: OptionButton
@export var resolution_option_button: OptionButton

const fps_values = {
	0: 0, 
	1: 60,
	2: 120,
	3: 144,
	4: 240
}
var resolutions = {
	"3840x2160": Vector2i(3840,2160),
	"3440x1440": Vector2i(3440,1440),
	"2560x1600": Vector2i(2560,1600),
	"2560x1440": Vector2i(2560,1440),
	"2560x1080": Vector2i(2560,1080),
	"1920x1200": Vector2i(1920,1200),
	"1920x1080": Vector2i(1920,1080),
	"1600x900": Vector2i(1600,900),
	"1440x900": Vector2i(1440,900),
	"1366x768": Vector2i(1366,768),
	"1280x800": Vector2i(1280,800),
	"1280x720": Vector2i(1280,720),
	"1024x768": Vector2i(1024,768)
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
	screen_option_button.select(Global.screen_mode)
	fps_option_button.select(Global.fps)
	if(Global.fps == 5):
		fps_custom_spinbox.show()
		fps_custom_spinbox.value = Engine.max_fps
	resolution_option_button.select(Global.screen_size)
	
	
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


func _on_quit_mm_button_pressed() -> void:
	if(get_tree().current_scene.scene_file_path == "res://Scenes/main_menu.tscn"):
		hide()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_d_button_pressed() -> void:
	get_tree().quit()


func _on_spin_box_value_changed(value: float) -> void:
	Global.sens_changed(value / 100)
	sensitivity_slider.value = value


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Global.sens_changed(value / 100)
	sensitivity_spin_box.value = value


func _on_fps_option_button_item_selected(index: int) -> void:
	Global.fps = index
	if(index == 5):
		if (fps_custom_spinbox.value == 1):
			fps_custom_spinbox.value = 240
		else:
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


func _on_screen_option_button_item_selected(index: int) -> void:
	match index:
		0:
			Global.screen_mode = 0
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var screen_size := DisplayServer.screen_get_size()
			var window_size := Vector2i(1280, 720)
			DisplayServer.window_set_size(window_size)
			@warning_ignore("integer_division")
			DisplayServer.window_set_position((screen_size - window_size) / 2)
		1:
			Global.screen_mode = 1
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			Global.screen_mode = 2
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_resolution_option_button_item_selected(index: int) -> void:
	Global.screen_size = index
	var key = resolution_option_button.get_item_text(index)
	DisplayServer.window_set_size(resolutions[key])
