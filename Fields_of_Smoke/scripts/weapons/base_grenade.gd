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
