extends RigidBody3D

@onready var explosion_effect: Node3D = $Explosion
@onready var damage_collision: CollisionShape3D = $DamageArea/DamageCollision

@export var base_damage: int = 150
@export var fuse_time: float = 4.0
@export var fuse_timer: Timer
@export var radius: float = 10.0

var bodies: Array[Node] = []


func _ready() -> void:
	damage_collision.shape.radius = radius
	fuse_timer.wait_time = fuse_time
	fuse_timer.start()


func _process(delta: float) -> void:
	pass
	

func _on_fuse_timeout() -> void:
	fuse_timer.stop()
	explosion_effect.reparent(get_parent())
	explosion_effect.explode()
	# apply damage
	for b in bodies:
		apply_damage(b)
	queue_free()
	

func apply_damage(body: Node):
	var distance = global_position.distance_to(body.global_position)
	var t = inverse_lerp(radius, 0.0, distance)
	var damage = base_damage * t
	body.health.take_damage(max(damage, 0.0))


func _on_damage_area_body_entered(body: Node3D) -> void:
	print("body: ", body)
	if "health" in body:
		print(body.health)
		bodies.append(body)
		


func _on_damage_area_body_exited(body: Node3D) -> void:
	if "health" in body:
		bodies.erase(body)
