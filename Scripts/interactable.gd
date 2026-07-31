extends StaticBody3D

class_name Interactable

@export var mesh: MeshInstance3D

var mesh_mat: StandardMaterial3D

func _ready() -> void:
	mesh.set_surface_override_material(0, mesh.get_active_material(0).duplicate())
	mesh_mat = mesh.get_active_material(0)
	
func get_interact_message(_player: Player) -> String:
	return "E"

func interact(_player: Player) -> void:
	print("Interactable.interact(%s)" % name)
	
func toggle_outline() -> void:
	if(mesh_mat.stencil_mode == BaseMaterial3D.StencilMode.STENCIL_MODE_DISABLED):
		mesh_mat.stencil_mode = BaseMaterial3D.StencilMode.STENCIL_MODE_OUTLINE
	else:
		mesh_mat.stencil_mode = BaseMaterial3D.StencilMode.STENCIL_MODE_DISABLED
