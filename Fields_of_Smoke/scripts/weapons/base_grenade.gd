extends RigidBody3D

class_name BaseGrenade


var current_ammo: int = 1
var full_ammo: int = 0

# weapon type
@export var weapon_slot: int = 0

# bullet stats
@export var fuse_time: int = 0
@export var damage: int = 0
var velocity = Vector3.ZERO
@export var bullet_hole_scene: PackedScene
@export var accuracy: float = 0.02

@export var fire_rate: float = 0.8
@export var reload_speed: float = 2.0

@export var clip_max_ammo: int = 10


# effects
#@onready var gunshot_sound = $GunshotSound
#@onready var reload_sound = $ReloadSound

@export var recoil_distance: float = -0.4
@export var recoil_speed: float = 20.0
@export var return_speed: float = 10.0
var recoil_offset: float = 0.0
var recoil_z: float = 0.0

@export var push_strength: float = 0.01

signal ammo_changed(current_ammo, full_ammo)

var can_shoot: bool = true
var is_reloading: bool = false

# who throws it
var wielder

# position
var is_ads: bool = false
@export var hip_position: Vector3
@export var ads_position: Vector3



func _ready() -> void:
	gravity_scale = 1.0
	linear_damp = 0.0
	
	if velocity != Vector3.ZERO:
		look_at(global_position + velocity, Vector3.UP)
