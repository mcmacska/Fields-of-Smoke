extends BaseItem

class_name BaseGrenade

@export var throwable_scene: PackedScene

var current_ammo: int = 1
var full_ammo: int = 2

# weapon type
@export var weapon_slot: int = 0

# bullet stats
@export var damage: int = 0
@export var throw_force = 1


func _ready() -> void:
	position = Vector3(0.45, 0.35, -0.6)
	fire_rate = 0.0
	reload_speed = 1.0
	clip_max_ammo = 1
	
	
func trigger_held(camera_transform: Transform3D):
	pass

func trigger_released(camera_transform: Transform3D):
	primary_action(camera_transform)
	
	
func primary_action(camera_transform: Transform3D):
	if not can_shoot or is_reloading:
		return
	# auto reload if empty
	if current_ammo <= 0:
		reload()
		return
	can_shoot = false
	print("throwing...")
	# TODO: animation
	var g = throwable_scene.instantiate()
	get_tree().current_scene.add_child(g)
	g.global_position = camera_transform.origin - camera_transform.basis.z * 0.5
	g.linear_velocity = -camera_transform.basis.z * throw_force
	# decrease current ammo
	current_ammo = current_ammo - 1
	ammo_changed.emit(current_ammo, full_ammo)
	# cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

	
func reload():
	if is_reloading or current_ammo == clip_max_ammo or full_ammo <= 0:
		return
	is_reloading = true
	can_shoot = false
	print("reloading...")
	#reload_sound.play() # TODO: sound
	# cooldown
	await get_tree().create_timer(reload_speed).timeout
	if not is_reloading:
		can_shoot = true
		return  # cancelled
	# decrease full ammo
	full_ammo = full_ammo - (clip_max_ammo - current_ammo)
	current_ammo = clip_max_ammo
	ammo_changed.emit(current_ammo, full_ammo)
	can_shoot = true
	is_reloading = false
