extends CanvasLayer

@onready var achies = $Achies

func _ready():
	get_tree().paused = false
	visible = false


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_exit_to_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")


func change_visibility(value: bool):
	achies.text = str(Achievements.stats)
	visible = value
