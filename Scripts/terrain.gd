@tool
extends MeshInstance3D
@export var size := 256.0:
	set(new_size):
		size = new_size
		if is_inside_tree():
			update_mesh()
@export_range(4, 256, 4) var resolution := 32:
	set(new_resolution):
		resolution = new_resolution
		if is_inside_tree():
			update_mesh()
@export var noise: FastNoiseLite:
	set(new_noise):
		noise = new_noise
		if is_inside_tree():
			update_mesh()
		if noise and not noise.changed.is_connected(update_mesh):
			noise.changed.connect(update_mesh)
@export_range(4.0, 128.0, 4.0) var height := 64.0:
	set(new_height):
		height = new_height
		if material_override:
			material_override.set_shader_parameter("height", height * 2.0)
		if is_inside_tree():
			update_mesh()
@export var tree_count: int = 256:
	set(new_count):
		tree_count = new_count
		if is_inside_tree():
			spawn_trees()
@export var tree_scene_1: PackedScene
@export var tree_scene_2: PackedScene
@export var tree_scene_3: PackedScene

func _ready() -> void:
	update_mesh()

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
	if not noise:
		return
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

	for child in get_children():
		if child is StaticBody3D:
			remove_child(child)
			child.free()
	create_trimesh_collision()

	spawn_trees()

func spawn_trees() -> void:
	if not is_inside_tree() or not noise:
		return
	var old_container := get_node_or_null("Trees")
	if old_container:
		remove_child(old_container)
		old_container.free()

	var tree_container := Node3D.new()
	tree_container.name = "Trees"
	add_child(tree_container)

	var trees := [tree_scene_1, tree_scene_2, tree_scene_3]
	for i in range(tree_count):
		var scene: PackedScene = trees[randi() % trees.size()]
		if not scene:
			continue
		var tree := scene.instantiate()
		tree_container.add_child(tree)
		var x := randf_range(-size / 2, size / 2)
		var z := randf_range(-size / 2, size / 2)
		var y: float = get_height(x, z)
		tree.position = Vector3(x, y - 0.7, z)
		tree.scale *= 1 + randf() * 1.5
