extends BaseGrenade


func _init():
	item_slot = 3
	throw_force = 10
	
	
func primary_action(camera_transform: Transform3D):
	var g = throwable_scene.instantiate()
	get_tree().current_scene.add_child(g)
	g.global_position = camera_transform.origin - camera_transform.basis.z * 0.5
	g.linear_velocity = -camera_transform.basis.z * throw_force
