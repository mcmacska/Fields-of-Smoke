extends Node3D


@onready var skeleton_sim = $"Armature/Skeleton3D/PhysicalBoneSimulator3D"
@onready var bone = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone torso"


func died(push: Vector3) -> void:
	start_timer()
	# start ragdoll
	skeleton_sim.active = true
	skeleton_sim.physical_bones_start_simulation()
	# apply push force
	bone.apply_central_impulse(push)


func start_timer():
	await get_tree().create_timer(60.0).timeout
	queue_free()
