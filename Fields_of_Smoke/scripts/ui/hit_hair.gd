extends TextureRect

@export var timer: Timer

func did_hit():
	visible = true
	timer.start()

func _on_timer_timeout() -> void:
	visible = false
