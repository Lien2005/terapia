extends Node3D

@onready var lightbulb: MeshInstance3D = $Light/Lightbulb
@onready var omni_light_3d: OmniLight3D = $Light/Lightbulb/OmniLight3D

@export var lightbulb_mat: BaseMaterial3D
@export var is_on: bool = false
@export var light_switch: LightSwitch

func _ready() -> void:
	if light_switch == null:
		return
	light_switch.TURN_SWITCH.connect(flip_light)

func flip_light() -> void:
	is_on = !is_on
	if is_on:
		omni_light_3d.show()
		lightbulb_mat.emission_enabled = true
	else:
		omni_light_3d.hide()
		lightbulb_mat.emission_enabled = false
