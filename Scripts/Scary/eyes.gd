extends MeshInstance3D

@onready var player = get_parent()

func _ready() -> void:
	top_level = true

func _physics_process(_delta: float) -> void:
	look_at(player.global_position)
	rotate_object_local(Vector3.UP, deg_to_rad(90))
	visible = true

func _on_timer_timeout() -> void:
	set_physics_process(false)
	visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
