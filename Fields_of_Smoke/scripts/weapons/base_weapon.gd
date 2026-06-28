extends BaseItem

class_name BaseWeapon


# bullet stats
@export var damage: int = 22
@export var bullet_hole_scene: PackedScene
@export var accuracy: float = 0.02

#var projectile_scene = preload("res://scenes/weapons/projectile3d.tscn")

@export var current_ammo: int = 10
@export var full_ammo: int = 100

# effects
@onready var gunshot_sound = $GunshotSound
@onready var reload_sound = $ReloadSound
@onready var muzzle_flash = $Muzzle/MuzzleFlash
@onready var flash = $Muzzle/Flash
const muzzle_flash_time: float = 0.05

@export var recoil_distance: float = -0.4
@export var recoil_speed: float = 20.0
@export var return_speed: float = 10.0
var recoil_offset: float = 0.0
var recoil_z: float = 0.0

@export var push_strength: float = -1.0


# position
var is_ads: bool = false
@export var hip_position: Vector3
@export var ads_position: Vector3

var camera_transform: Transform3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = hip_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	recoil_offset = move_toward(
		recoil_offset,
		0.0,
		return_speed * delta
	)
	
	var target = ads_position if is_ads else hip_position
	var base_pos = position.lerp(target, 1.0 - exp(-32.0 * delta))
	recoil_z = lerp(recoil_z, -recoil_offset, recoil_speed * delta)
	position = base_pos + Vector3(0, 0, recoil_z)


func primary_action(camera_transform: Transform3D):
	if not can_shoot or is_reloading:
		return
	# auto reload if empty
	if current_ammo <= 0:
		reload()
		return
	can_shoot = false
	print("shooting...")
	# cast ray
	create_ray(camera_transform, wielder)
	# add effects
	await shooting_effects()
	# add to the scene tree
	#get_tree().current_scene.add_child(projectile)
	# decrease current ammo
	current_ammo = current_ammo - 1
	ammo_changed.emit(current_ammo, full_ammo)
	# cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


func secondary_action(ads: bool):
	is_ads = ads

	
func create_ray(camera_transform: Transform3D, shooter: CharacterBody3D):
	var from = camera_transform.origin
	var direction = -camera_transform.basis.z
	# intentional innaccuracy
	direction += Vector3(
		randf_range(-accuracy, accuracy),
		randf_range(-accuracy, accuracy),
		randf_range(-accuracy, accuracy)
	)
	direction = direction.normalized()
	var to = from + direction * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		spawn_bullet_hole(result)
		apply_damage(result.collider, shooter)
		set_push_strength(result.collider, direction)
		
		
func apply_damage(body: Node3D, shooter: CharacterBody3D):
	print("Detected:", body.name)
	var is_player = false
	if body.is_in_group("friends") and shooter.is_in_group("friends"):
		return
	if body.is_in_group("enemies") and shooter.is_in_group("enemies"):
		return
	elif body.is_in_group("enemies") and shooter.is_in_group("player"):
		shooter._on_hit()
		
	var health = body.get_node_or_null("Health")
	if health:
		health.take_damage(damage)


func spawn_bullet_hole(hit):
	var hole = bullet_hole_scene.instantiate()
	get_tree().current_scene.add_child(hole)
	hole.global_transform.origin = hit.position
	# Align decal to surface normal
	hole.look_at(hit.position + hit.normal, Vector3.UP)
	
	
func set_push_strength(body: Node3D, direction:  Vector3):
	if body.has_method("set_push_strength"):
		body.set_push_strength(push_strength, direction)
	

func reload():
	if is_reloading or current_ammo == clip_max_ammo or full_ammo <= 0:
		return
	is_reloading = true
	can_shoot = false
	print("reloading...")
	reload_sound.play()
	# cooldown
	await get_tree().create_timer(reload_speed).timeout
	if not is_reloading:
		can_shoot = true
		return  # cancelled
	# decrease full ammo
	var ammo_needed = clip_max_ammo - current_ammo
	var ammo_to_load = min(ammo_needed, full_ammo)
	current_ammo += ammo_to_load
	full_ammo -= ammo_to_load
	ammo_changed.emit(current_ammo, full_ammo)
	can_shoot = true
	is_reloading = false


func cancel_reload():
	is_reloading = false


func shooting_effects():
	if wielder and wielder.has_method("add_recoil_effect"):
		wielder.add_recoil_effect()
	gunshot_sound.pitch_scale = randf_range(0.95, 1.05)
	gunshot_sound.play()
	# Random rotation in radians
	muzzle_flash.rotation.z = randf_range(0.0, TAU)
	flash.visible = true
	muzzle_flash.visible = true
	await get_tree().create_timer(muzzle_flash_time).timeout
	muzzle_flash.visible = false
	flash.visible = false
	# recoil
	recoil_offset = recoil_distance
	
