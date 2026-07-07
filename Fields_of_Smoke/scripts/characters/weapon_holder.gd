extends Node3D

@export var camera_p: Node3D
@export var player: CharacterBody3D
@export var is_ads: float
var lerpy: float = 0.2
var wall_offset: float = 0.0

func _process(_delta: float) -> void:
	if not player or not camera_p:
		return
	global_position = player.global_position
	
	if is_ads:
		rotation.x = camera_p.rotation.x + wall_offset
		global_rotation.y = player.global_rotation.y
		rotation.z = lerp(rotation.z, camera_p.rotation.z+ wall_offset, lerpy)
	else:
		rotation.x = lerp(rotation.x, camera_p.rotation.x + wall_offset, lerpy)
		var target_rotation_y = player.global_rotation.y
		global_rotation.y = lerp_angle(global_rotation.y, target_rotation_y, lerpy)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("player")):
		return
	wall_offset = deg_to_rad(45)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.is_in_group("player")):
		return
	wall_offset = 0.0
