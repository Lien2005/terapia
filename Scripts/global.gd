extends Node

signal change_sens(value)

var start_sens: float = 0.01
var sensitivity: float = clamp(start_sens, 0.001, 0.050)
var brightness: float = 1.0
var contrast: float = 1.0
var display_fps: bool = false
var screen_mode: int = 0
var fps = 4
var screen_size: int = 6

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func sens_changed(value) -> void:
	sensitivity = value
	change_sens.emit(value)
