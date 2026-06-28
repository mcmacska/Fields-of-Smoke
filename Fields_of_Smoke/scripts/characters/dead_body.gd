extends Node3D


@onready var skeleton_sim = $"Armature/Skeleton3D/PhysicalBoneSimulator3D"
@onready var bone = $"Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone Bone"
@onready var timer = $"Timer"


func _ready() -> void:
	timer.wait_time = 1 * 60
	timer.start()
	skeleton_sim.physical_bones_start_simulation()


func hitbone(push: Vector3) -> void:
	bone.apply_central_impulse(push)


func _on_timer_timeout() -> void:
	queue_free()
