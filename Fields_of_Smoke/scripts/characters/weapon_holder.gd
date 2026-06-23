extends Node3D

@export var camera_p: Node3D
@export var player: CharacterBody3D
var lerpy: float = 0.2

func _process(_delta: float) -> void:
	if not player or not camera_p:
		return
	global_position = player.global_position
	
	rotation.x = lerp(rotation.x, camera_p.rotation.x, lerpy)
	
	var target_rotation_y = player.global_rotation.y
	global_rotation.y = lerp_angle(global_rotation.y, target_rotation_y, lerpy)
