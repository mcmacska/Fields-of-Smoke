extends BaseAttack

class_name BaseStates

enum State {
	PATROL,
	CHASE,
	ATTACK,
	CAPTURE
}

# navigation
@export var nav_agent_3d: NavigationAgent3D
const UPDATE_TIME: float = 0.2
const SMOOTHING_FACTOR: float = 0.1

var update_timer: float = 0.0

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
	
	update_timer -= delta
	
	match current_state:
		State.CHASE:
			chase(delta)
		State.ATTACK:
			attack(delta)
		State.CAPTURE:
			capture(delta)
		State.PATROL:
			patrol(delta)


func chase(delta):
	if not target:
		return Vector3.ZERO

	# tell navigation agent where we want to go
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		set_target(target.global_position)
	
	# Navigation is finished / no path available.
	if nav_agent_3d.is_navigation_finished():
		velocity = Vector3.ZERO
		return
	# get the next point along the navigation path.
	var next_position := nav_agent_3d.get_next_path_position()
	# move toward that point instead of directly toward base.
	var dir := global_position.direction_to(next_position)
	
	rotate_towards(dir, delta)
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
	#print("global scale: ", global_transform.basis.get_scale())
	#print("position: ", global_position)
	# tell navigation agent where we want to go
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		set_target(base.global_position)
	
	# stop when close enough
	if global_position.distance_to(base.global_position) < 8.0:
		velocity = Vector3.ZERO
		return
	# Navigation is finished / no path available.
	if nav_agent_3d.is_navigation_finished():
		velocity = Vector3.ZERO
		return
	# get the next point along the navigation path.
	var next_position := nav_agent_3d.get_next_path_position()
	
	# move toward that point instead of directly toward base.
	var dir := global_position.direction_to(next_position)
	
	rotate_towards(dir, delta)
	#velocity = dir.normalized() * speed
	velocity = dir * speed


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


func set_target(target_position: Vector3):
	nav_agent_3d.target_position = target_position
