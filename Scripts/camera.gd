extends CharacterBody3D

@export var flashlight: SpotLight3D
@export var footstep_stream_player_3d: AudioStreamPlayer3D
@export var eyes: PackedScene

var speed: float
var walk_speed: float = 3.0
var sprint_speed: float = 6.0
var jump_velocity: float = 4.8
var sensitivity: float = Global.sensitivity

#bob variables
var bob_freq: float = 2.4
var bob_amp: float = 0.08
var t_bob: float = 0.0
var footstep_can_play: bool = true
var footstep_landed: bool

#fov variables
var base_fov: float = 75.0
const fov_change: float = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.change_sens.connect(_change_sens)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else:
		speed = walk_speed

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()
	
	if not footstep_landed and is_on_floor():
		footstep_stream_player_3d.play()
	elif footstep_landed and not is_on_floor():
		footstep_stream_player_3d.play()
	footstep_landed = is_on_floor()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	
	var footstep_threshold = -bob_amp + 0.04
	if pos.y > footstep_threshold:
		footstep_can_play = true
	elif pos.y < footstep_threshold and footstep_can_play:
		footstep_can_play = false
		footstep_stream_player_3d.play()
	return pos

func _change_sens(value) -> void:
	sensitivity = value


func _on_timer_timeout() -> void:
	if flashlight.visible:
		return
	var eye = eyes.instantiate()
	var eye_spawn_location = %EyeLocation
	eye_spawn_location.progress_ratio = randf()
	eye.visible = false
	add_child(eye)
	eye.global_position = eye_spawn_location.global_position
