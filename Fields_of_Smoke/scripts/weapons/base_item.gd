extends Node3D

class_name BaseItem

# weapon type
@export var item_slot: int = 0

func primary_action(camera_transform: Transform3D):
	pass

func secondary_action():
	pass
