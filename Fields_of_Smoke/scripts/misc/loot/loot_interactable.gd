extends Interactable

signal did_interact

func _ready() -> void:
	Name = "Ammo"

func interact(_body: Node3D):
	#body.add_ammo()
	did_interact.emit()
