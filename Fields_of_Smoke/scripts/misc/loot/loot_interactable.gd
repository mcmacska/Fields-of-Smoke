extends Interactable

signal did_interact

func interact(body: Node3D):
	#body.add_ammo()
	did_interact.emit()
