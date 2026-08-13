extends RigidBody3D

@onready var explosion_effect: Node3D = $Explosion
@onready var damage_collision: CollisionShape3D = $DamageArea/DamageCollision
@onready var explosion_sound = $ExplosionSound
@export var base_damage: int = 150
@export var fuse_time: float = 4.0
@export var fuse_timer: Timer
@export var radius: float = 10.0
@export var push_strength: float = -10.0

var bodies: Array[Node] = []


func _ready() -> void:
	damage_collision.shape.radius = radius
	fuse_timer.wait_time = fuse_time
	fuse_timer.start()


func _process(delta: float) -> void:
	pass
	

func _on_fuse_timeout() -> void:
	fuse_timer.stop()
	# apply damage
	for b in bodies:
		apply_damage(b)
		var direction = (b.global_position - global_position).normalized()
		set_push_strength(b, direction)
	await explosion_effects()
	queue_free()
	

func apply_damage(body: Node):
	var distance = global_position.distance_to(body.global_position)
	var t = inverse_lerp(radius, 0.0, distance)
	var damage = base_damage * t
	var health = body.get_node_or_null("Health")
	if health:
		health.take_damage(max(damage, 0.0))


func explosion_effects():
	explosion_effect.reparent(get_parent())
	explosion_effect.explode()
	explosion_sound.pitch_scale = randf_range(0.95, 1.05)
	explosion_sound.play()
	await explosion_sound.finished


func set_push_strength(body: Node3D, direction:  Vector3):
	if body.has_method("set_push_strength"):
		body.set_push_strength(push_strength, direction)
		

func _on_damage_area_body_entered(body: Node3D) -> void:
	print("body: ", body)
	if "health" in body:
		print(body.health)
		bodies.append(body)
		


func _on_damage_area_body_exited(body: Node3D) -> void:
	if "health" in body:
		bodies.erase(body)
