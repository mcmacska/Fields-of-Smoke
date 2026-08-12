extends Node3D


@onready var skeleton_sim = $"Armature/Skeleton3D/PhysicalBoneSimulator3D"
@onready var bone = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone torso"
@onready var timer = $"Timer"


func died(push: Vector3) -> void:
	timer.wait_time = 60.0
	timer.start()
	# start ragdoll
	skeleton_sim.active = true
	skeleton_sim.physical_bones_start_simulation()
	# apply push force
	bone.apply_central_impulse(push)


func _on_timer_timeout() -> void:
	queue_free()
