extends RigidBody3D

@onready var explosion_effect = $Explosion

@export var damage: int = 50
@export var fuse_time: float = 4.0
@export var fuse_timer: Timer

var bodies: Array[Node] = []


func _ready() -> void:
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
		# TODO: damage falloff
		b.health.take_damage(damage)
	queue_free()
	


func _on_damage_area_body_entered(body: Node3D) -> void:
	print("body: ", body)
	if "health" in body:
		print(body.health)
		bodies.append(body)
		


func _on_damage_area_body_exited(body: Node3D) -> void:
	if "health" in body:
		bodies.erase(body)
