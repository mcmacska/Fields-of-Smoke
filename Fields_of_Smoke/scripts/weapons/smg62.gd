extends BaseWeapon

func _init():
	weapon_slot = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	accuracy = 0.01
	damage = 8
	fire_rate = 0.08
	reload_speed = 2.5
	current_ammo = 30
	clip_max_ammo = 30
	full_ammo = 120
	# recoil
	recoil_distance = -0.2
	recoil_speed = 20.0
	return_speed = 10.0
	# position
	hip_position = Vector3(0.2, 0.37, -0.25)
	ads_position = Vector3(0, 0.498, -0.07)


func trigger_held(camera_transform: Transform3D):
	shoot(camera_transform)
