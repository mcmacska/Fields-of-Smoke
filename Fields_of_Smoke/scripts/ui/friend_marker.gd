extends Node3D

@export var animp: AnimationPlayer
@export var marker: MeshInstance3D

func _ready() -> void:
	animp.play("Spawn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name != "Death"):
		animp.play("Spin")
