extends Node3D

class_name BaseItem

# weapon type
@export var item_slot: int = 0

@export var fire_rate: float = 0.8
@export var reload_speed: float = 0.8
@export var clip_max_ammo: int = 10
var is_reloading: bool = false
var can_shoot: bool = true

var wielder

@warning_ignore("unused_signal")
signal ammo_changed(current_ammo, full_ammo)

func trigger_pressed(_camera_trans: Transform3D):
	pass

func trigger_held(_camera_trans: Transform3D):
	pass

func trigger_released(_camera_trans: Transform3D):
	pass


func primary_action(_camera_trans: Transform3D):
	pass

func secondary_action(_ads: bool):
	pass

func reload():
	pass

func cancel_reload():
	pass
