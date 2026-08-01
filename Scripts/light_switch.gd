extends Interactable

class_name LightSwitch

@export var is_on: bool = false
@export var switch: MeshInstance3D
@export var audio_stream_player_3d: AudioStreamPlayer3D

signal TURN_SWITCH

func interact(_player: Player) -> void:
	TURN_SWITCH.emit()
	audio_stream_player_3d.play()
	is_on = not is_on
	if is_on:
		switch.rotation_degrees.x = 45
	else:
		switch.rotation_degrees.x = 145
