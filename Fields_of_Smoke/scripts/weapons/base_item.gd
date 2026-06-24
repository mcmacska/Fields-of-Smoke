extends Node3D

class_name BaseItem

# weapon type
@export var item_slot: int = 0

@export var fire_rate: float = 0.8
var can_shoot: bool = true

var wielder


signal ammo_changed(current_ammo, full_ammo)



func trigger_pressed(camera_transform: Transform3D):
	pass

func trigger_held(camera_transform: Transform3D):
	pass

func trigger_released(camera_transform: Transform3D):
	pass


func primary_action(camera_transform: Transform3D):
	pass

func secondary_action(ads: bool):
	pass

func reload():
	pass

func cancel_reload():
	pass
