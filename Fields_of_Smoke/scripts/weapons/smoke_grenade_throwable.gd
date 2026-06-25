extends RigidBody3D

@export var fuse_time: float = 4.0
@export var smoke_duration: float = 10.0

@export var fuse_timer: Timer
@export var smoke_timer: Timer
@export var smoke_cloud: FogVolume


func _ready() -> void:
	print(smoke_timer.timeout.is_connected(_on_smoke_timer_timeout))
	fuse_timer.wait_time = fuse_time
	smoke_timer.wait_time = smoke_duration
	fuse_timer.start()


func _process(delta: float) -> void:
	pass
	

func _on_fuse_timeout() -> void:
	fuse_timer.stop()
	smoke_timer.start()
	grenade_effects()


func _on_smoke_timer_timeout() -> void:
	queue_free()
	
	
func grenade_effects():
	smoke_cloud.visible = true
