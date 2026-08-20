extends Node3D

@export var camera_p: Node3D
@export var player: CharacterBody3D
@export var is_ads: bool # Átírva bool-ra

var lerpy_speed: float = 14.0 # Sima átmenet sebessége
var wall_offset: float = 0.0

func _process(delta: float) -> void:
	if not player or not camera_p:
		return
		
	# A pozíció követi a játékost
	global_position = player.global_position
	
	if wall_offset != 0:
		player.can_ads = false
	else:
		player.can_ads = true
	# 1. Kiszámoljuk a kívánt X dőlést (Pitch)
	var raw_pitch = camera_p.rotation.x + wall_offset
	# KORLÁTOZÁS: Megakadályozzuk, hogy a dőlés elérje vagy meghaladja a 90 fokot (±85 fokra szűkítjük)
	var target_pitch = clamp(raw_pitch, deg_to_rad(-85.0), deg_to_rad(85.0))
	
	var target_yaw = player.global_rotation.y
	var target_roll = camera_p.rotation.z
	
	# Sima delta-alapú interpoláció
	var weight = 1.0 - exp(-lerpy_speed * delta)
	
	if is_ads:
		rotation.x = target_pitch
		global_rotation.y = target_yaw
		rotation.z = lerp_angle(rotation.z, target_roll, weight)
	else:
		rotation.x = lerp_angle(rotation.x, target_pitch, weight)
		global_rotation.y = lerp_angle(global_rotation.y, target_yaw, weight)
		rotation.z = lerp_angle(rotation.z, target_roll, weight)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		return
	wall_offset = deg_to_rad(45.0)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		return
	wall_offset = 0.0
