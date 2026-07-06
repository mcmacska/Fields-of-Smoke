extends ColorRect

@export var fade_speed := 1.0

var current_alpha := 0.0

func _ready() -> void:
	_set_shader_intensity(0.0)

func _process(delta: float) -> void:
	current_alpha = move_toward(current_alpha, 0.0, fade_speed * delta)
	_set_shader_intensity(current_alpha)

func show_damage(strength := 0.5):
	current_alpha = clamp(strength + randf_range(-0.1, 0.1), 0.0, 1.0)
	_set_shader_intensity(current_alpha)
	
	var rand_x = randf_range(-0.5, 0.5)
	var rand_y = randf_range(-0.5, 0.5)
	
	if material and material is ShaderMaterial:
		material.set_shader_parameter("random_offset", Vector2(rand_x, rand_y))

func _set_shader_intensity(value: float) -> void:
	if material and material is ShaderMaterial:
		material.set_shader_parameter("blood_intensity", value)
