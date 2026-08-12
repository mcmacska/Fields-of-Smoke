extends BaseStates

class_name BaseCharacter2

#var current_target: Node2D = null

@onready var body = $Body

var push_direction: Vector3 = Vector3()

func _process(_delta):
	if is_dead || get_tree().paused:
		return

func _physics_process(delta: float) -> void:
	if is_dead || get_tree().paused:
		return
	
	# Add the gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	elif velocity.y < 0:
		velocity.y = 0
	
	update_state(delta)
	
	move_and_slide()


func set_push_strength(strength, direction):
	push_strength = strength
	push_direction = direction


func _on_health_died() -> void:
	is_dead = true
	died.emit()
	body.global_transform = global_transform
	body.reparent(get_parent(), true)
	body.died(push_direction.normalized() * push_strength)
	queue_free()
	
