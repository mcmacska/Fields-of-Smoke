extends TextureRect

@export var fade_speed := 1.0

var current_alpha := 0.0

func _ready() -> void:
	modulate.a = 0.0


func _process(delta: float) -> void:
	current_alpha = move_toward(current_alpha, 0.0, fade_speed * delta)
	modulate.a = current_alpha


func show_damage(strength := 0.5):
	current_alpha = clamp(strength, 0.0, 1.0)
	modulate.a = current_alpha
