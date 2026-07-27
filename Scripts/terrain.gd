@tool
extends MeshInstance3D
@export_range(4, 2048, 4) var size := 256.0:
	set(new_size):
		size = new_size
		update_mesh()
@export_range(4, 256, 4) var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		update_mesh()
@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		update_mesh()
		if noise:
			noise.changed.connect(update_mesh)
@export_range(4.0, 128.0, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		if material_override:
			material_override.set_shader_parameter("height", height * 2.0)
		update_mesh()

@export var tree_count: int = 256:
	set(new_count):
		tree_count = new_count
		spawn_trees()

@export var tree_scene_1: PackedScene
@export var tree_scene_2: PackedScene
@export var tree_scene_3: PackedScene

func get_height(x: float, y: float) -> float:
	return noise.get_noise_2d(x + position.x, y + position.z) * height

func get_normal(x: float, y: float) -> Vector3:
	var epsilon := size / resolution
	var normal := Vector3(
		(get_height(x + epsilon, y) - get_height(x - epsilon, y)) / (2.0 * epsilon),
		1.0,
		(get_height(x, y + epsilon) - get_height(x, y - epsilon)) / (2.0 * epsilon),
	)
	return normal.normalized()

func update_mesh() -> void:
	var plane := PlaneMesh.new()
	plane.subdivide_depth = resolution
	plane.subdivide_width = resolution
	plane.size = Vector2(size, size)

	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array: PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array: PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]

	for i:int in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT
		if noise:
			vertex.y = get_height(vertex.x, vertex.z)
			normal = get_normal(vertex.x, vertex.z)
			tangent = normal.cross(Vector3.UP)
		vertex_array[i] = vertex
		normal_array[i] = normal
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	mesh = array_mesh

	update_collision(array_mesh)

func update_collision(array_mesh: ArrayMesh) -> void:
	var static_body := get_node_or_null("StaticBody3D") as StaticBody3D
	var collision_shape: CollisionShape3D

	if static_body == null:
		static_body = StaticBody3D.new()
		static_body.name = "StaticBody3D"
		add_child(static_body)
		if Engine.is_editor_hint():
			static_body.owner = get_tree().edited_scene_root
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		static_body.add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.owner = get_tree().edited_scene_root
	else:
		collision_shape = static_body.get_node("CollisionShape3D")

	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(array_mesh.get_faces())
	collision_shape.shape = shape

func spawn_trees() -> void:
	if not noise:
		return

	var tree_container := get_node_or_null("Trees") as Node3D
	if tree_container == null:
		tree_container = Node3D.new()
		tree_container.name = "Trees"
		add_child(tree_container)
		if Engine.is_editor_hint():
			tree_container.owner = get_tree().edited_scene_root
	else:
		for child in tree_container.get_children():
			child.queue_free()

	var trees := [tree_scene_1, tree_scene_2, tree_scene_3]
	for i in range(tree_count):
		var scene: PackedScene = trees[randi() % trees.size()]
		if not scene:
			continue
		var tree := scene.instantiate()
		tree_container.add_child(tree)
		if Engine.is_editor_hint():
			tree.owner = get_tree().edited_scene_root
		var x := randf_range(-size / 2, size / 2)
		var z := randf_range(-size / 2, size / 2)
		var y: float = get_height(x, z)
		tree.position = Vector3(x, y - 0.7, z)
		tree.scale *= 1 + randf() * 1.5
