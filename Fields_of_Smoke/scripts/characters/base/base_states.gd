extends BaseAttack

class_name BaseStates

enum State {
	PATROL,
	CHASE,
	ATTACK,
	CAPTURE
}

var current_state = State.PATROL
var current_point_index := 0
var target
var base

func update_state(delta):
	target = get_closest_target()
	base = get_closest_base()
	# if it can see the target, attack it
	if target:
		if global_position.distance_to(target.global_position) < attack_range:
			current_state = State.ATTACK
		else:
			current_state = State.CHASE
	elif base && should_capture:
		current_state = State.CAPTURE
	else:
		# go back to patrolling
		current_state = State.PATROL
	
	match current_state:
			State.CHASE:
				chase()
			State.ATTACK:
				attack(delta)
			State.CAPTURE:
				capture(delta)
			State.PATROL:
				patrol(delta)


func chase():
	if not target:
		return Vector3.ZERO
	
	var dir = (target.global_position - global_position)
	if dir.length_squared() < 0.000001:
		return Vector3.ZERO # prevent invalid basis
	
	velocity = dir.normalized() * speed

#bad
func attack(delta):
	if not target:
		return
	
	if target.is_dead:
		targets.erase(target)
		target = null
		return
	
	velocity = Vector3.ZERO
	
	var dir = target.global_position - global_position
	rotate_towards(dir, delta)
	if is_aiming_at_target(target):
		weapon_shooting()


func capture(delta):
	if not base:
		return
	
	var dir = base.global_position - global_position
	if dir.length_squared() < 0.000001:
		return # prevent invalid basis
	
	# rotate like before
	rotate_towards(dir, delta)
	
	if global_position.distance_to(base.global_position) < 8:
		velocity = Vector3.ZERO
	else:
		velocity = dir.normalized() * speed


func patrol(delta):
	if patrol_points.is_empty():
		return
	
	var patrol_target = patrol_points[current_point_index]
	var dir = (patrol_target.global_position - global_position)
	if dir.length_squared() < 0.000001:
		return # prevent invalid basis
	
	rotate_towards(dir, delta)
	if dir.length() < 5:
		current_point_index = (current_point_index + 1) % patrol_points.size()
		return
	
	velocity = dir.normalized() * speed
