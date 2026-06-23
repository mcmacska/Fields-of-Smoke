extends BaseCharacter

@export var should_capture_: bool = true

func _ready() -> void:
	dead_scene = preload("res://scenes/characters/enemy_dead.tscn")
	friends_group_name = "enemies"
	enemies_group_name = "friends"
	should_capture = should_capture_
	super._ready()
