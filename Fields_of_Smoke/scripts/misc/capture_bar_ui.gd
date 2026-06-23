extends Control


@export var max_progress: float = 100.0
@export var team_color: Color
@onready var progress_bar := $ProgressBar
@onready var bar_name := $Name
var style = StyleBoxFlat.new()
@onready var camera = get_viewport().get_camera_3d()


func _ready() -> void:
	pass
	
	
func setup_bar(max_value: float, name: String):
	progress_bar.max_value = max_value
	bar_name.text = name
	
	
func set_progress(progress: float, color: Color):
	progress_bar.value = progress
	# change color
	style.bg_color = color
	progress_bar.add_theme_stylebox_override("fill", style)
	
