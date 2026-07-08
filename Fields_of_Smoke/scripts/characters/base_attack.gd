extends BaseHelper

class_name BaseAttack

func weapon_shooting():
	if weapon.full_ammo < 1:
		print("no ammo")
		return
	
	if weapon.current_ammo < 1:
		weapon.reload()
	else:
		pass
		weapon.primary_action(muzzle.global_transform)


func is_aiming_at_target(target: Node3D) -> bool:
	var dir = target.global_position - global_position
	if dir.length_squared() < 0.000001:
		return false
	
	var to_target = dir.normalized()
	var forward = -global_transform.basis.z
	var dot = forward.dot(to_target)
	
	#10 degrees tolerance
	return dot > cos(deg_to_rad(10.0))


func rotate_towards(dir: Vector3, delta: float) -> void:
	var target_basis = Basis.looking_at(dir, Vector3.UP)
	
	global_transform.basis = global_transform.basis.slerp(
		target_basis,
		5.0 * delta
	)


func take_damage(amount):
	print("damage taken: ", amount)
	health -= amount
	health_changed.emit(health, max_health)
	
	if health <= 0:
		died.emit()


func heal(amount):
	health += amount
	if health > max_health:
		health = max_health
	
	health_changed.emit(health, max_health)
