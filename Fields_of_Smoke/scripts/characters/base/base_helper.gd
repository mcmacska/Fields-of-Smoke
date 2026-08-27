extends BaseStats

class_name BaseHelper

func get_closest_base() -> Node3D:
	var closest = null
	var min_dist = INF
	for b in bases:
		if not is_instance_valid(b):
			continue
		
		# optional: skip already owned bases
		if b.base_owner == friends_group_name:
			continue
		
		var dist = global_position.distance_to(b.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = b
	
	return closest


func get_closest_target():
	var closest: Node3D = null
	var closest_distance = INF
	for t in targets:
		if not is_instance_valid(t) or !create_ray(t):
			continue

		var dist = global_position.distance_to(t.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest = t
	
	return closest


func create_ray(body: Node3D) -> bool:
	var from = global_position + eye_level_origin
	var to = body.global_position
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.collider == body # print("somebody touched my spaget")
	return false

func drop():
	if loot:
		var drop_instance = loot.instantiate()
		
		get_parent().add_child(drop_instance)
		
		drop_instance.global_position = global_position
