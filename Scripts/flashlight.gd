extends SpotLight3D

@export var progress_bar: ProgressBar
@export var flashlight_stream_player_3d: AudioStreamPlayer3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight") and progress_bar.value > 0:
		visible = not visible
		flashlight_stream_player_3d.play()

func _physics_process(_delta: float) -> void:
	if not visible:
		return
	progress_bar.value -= 1
	if progress_bar.value == 0:
		visible = false
