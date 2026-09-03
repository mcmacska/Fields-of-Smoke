extends CanvasLayer

func _ready() -> void:
	visible = false
	

func start():
	visible = true

func _on_respawn_pressed() -> void:
	pass # Replace with function body.


func _on_exit_to_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")
