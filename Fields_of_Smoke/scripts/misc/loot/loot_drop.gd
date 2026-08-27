extends CharacterBody3D
class_name Drop

@export var scatter_force_min: float = 2.0
@export var scatter_force_max: float = 4.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animp = $AnimationPlayer
@onready var area = $Pivot/Area3D

func _ready() -> void:
	_prevent_spawn_overlap()

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		animp.stop()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.x = move_toward(velocity.x, 0, delta * 8.0)
		velocity.z = move_toward(velocity.z, 0, delta * 8.0)

	move_and_slide()

	if is_on_floor() and velocity.length() < 0.1:
		velocity = Vector3.ZERO
		collision_layer = 0
		set_physics_process(false)


func _prevent_spawn_overlap() -> void:
	#if test_move(global_transform, Vector3.ZERO):
		#global_position.y += 0.5
	#else:
	var random_x = randf_range(-1.0, 1.0)
	var random_z = randf_range(-1.0, 1.0)
	var random_dir = Vector3(random_x, 1.2, random_z).normalized()
	var force = randf_range(scatter_force_min, scatter_force_max)
	velocity = random_dir * force


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "despawn":
		queue_free()


func _on_pivot_did_interact() -> void:
	area.collision_layer = 0
	area.collision_mask = 0
	animp.play("despawn")
