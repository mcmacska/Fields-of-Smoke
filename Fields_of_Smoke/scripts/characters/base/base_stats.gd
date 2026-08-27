extends CharacterBody3D

class_name BaseStats


@onready var muzzle: Node3D = $Muzzle
@onready var body = $Body
@export var weapon: Node3D
@export var loot: PackedScene

@export var max_health = 100
var health

# var direction := Vector2.LEFT
@export var attack_range := 500
@export var dead_scene: Resource
@export var speed: float = 10.0
var patrol_points: Array[Node] = []
@export var friends_group_name: String = ""
@export var enemies_group_name: String = ""
@export var should_capture: bool = true

var eye_level_origin := Vector3(0, 0.5, 0)
var distance_moved = 0
@export var push_strength: float = 1.0
var is_dead = false
var bases: Array[Node] = []
var base_target: Node
var targets: Array = []

signal died()
signal health_changed(current, max)

func _ready() -> void:
	# set capture points
	health = max_health
	bases = get_tree().get_nodes_in_group("capture_points")
	print("bases: ", bases)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group(enemies_group_name):
		targets.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group(enemies_group_name):
		targets.erase(body)
