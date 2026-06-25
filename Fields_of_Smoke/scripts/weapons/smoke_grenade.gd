extends BaseGrenade


func _init():
	item_slot = 3
	throw_force = 10
	
	
func primary_action(camera_transform: Transform3D):
	if not can_shoot or is_reloading:
		return
	# auto reload if empty
	if current_ammo <= 0:
		reload()
		return
	can_shoot = false
	print("throwing...")
	# TODO: animation
	var g = throwable_scene.instantiate()
	get_tree().current_scene.add_child(g)
	g.global_position = camera_transform.origin - camera_transform.basis.z * 0.5
	g.linear_velocity = -camera_transform.basis.z * throw_force
	# decrease current ammo
	current_ammo = current_ammo - 1
	ammo_changed.emit(current_ammo, full_ammo)
	# cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


func reload():
	if is_reloading or current_ammo == clip_max_ammo or full_ammo <= 0:
		return
	is_reloading = true
	can_shoot = false
	print("reloading...")
	#reload_sound.play() # TODO: sound
	# cooldown
	await get_tree().create_timer(reload_speed).timeout
	if not is_reloading:
		can_shoot = true
		return  # cancelled
	# decrease full ammo
	full_ammo = full_ammo - (clip_max_ammo - current_ammo)
	current_ammo = clip_max_ammo
	ammo_changed.emit(current_ammo, full_ammo)
	can_shoot = true
	is_reloading = false
