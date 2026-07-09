extends BaseWeapon

func _init():
	item_slot = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	accuracy = 0.01
	damage = 16
	fire_rate = 0.025
	reload_speed = 4.0
	current_ammo = 100
	clip_max_ammo = 100
	full_ammo = 300
	# recoil
	recoil_distance = -0.1
	recoil_speed = 16.0
	return_speed = 8.0
	# position
	hip_position = Vector3(0, 0.498, -0.12)
	ads_position = Vector3(0, 0.498, -0.12)


func trigger_held(camera_transform: Transform3D):
	primary_action(camera_transform)
