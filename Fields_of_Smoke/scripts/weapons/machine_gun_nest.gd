extends Interactable

@onready var yaw_pivot = $YawPivot
@onready var pitch_pivot = $YawPivot/PitchPivot
@onready var weapon = $YawPivot/PitchPivot/Weapon
@onready var area = $Area3D
@onready var seat_marker = $YawPivot/SeatMarker
@onready var exit_marker = $ExitMarker
@onready var bullet_origin = $YawPivot/PitchPivot/Weapon/BulletOrigin
@onready var camera_position = $YawPivot/PitchPivot/CameraPosition
@export var sensitivity: float = 0.002
@export var timer: Timer
var just_entered = true

var yaw := 0.0
var pitch := 0.0

var current_user: Node = null
var original_camera_parent: Node
var original_camera_pivot_transform: Transform3D
var original_weapon_index: int = 0
var can_use = true

func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if current_user == null:
		return
	if get_tree().paused:
		return
	if event.is_action_released("use"):
		just_entered = false
		return
	if event.is_action_pressed("use"):
		if just_entered:
			return
		get_viewport().set_input_as_handled()
		leave_mg(current_user)
		get_tree().create_timer(0.5).timeout.connect(_on_timer_timeout)
		can_use = false
		just_entered = true
		return
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		
		yaw = clamp(yaw, deg_to_rad(-80), deg_to_rad(80))
		pitch = clamp(pitch, deg_to_rad(-20), deg_to_rad(35))
		
		yaw_pivot.rotation.y = yaw
		pitch_pivot.rotation.x = pitch


func _physics_process(_delta: float) -> void:
	if get_tree().paused:
		return
	if current_user == null:
		return

	if Input.is_action_pressed("shoot"):
		weapon.trigger_held(bullet_origin.global_transform)
	if Input.is_action_just_pressed("shoot"):
		weapon.trigger_pressed(bullet_origin.global_transform)
	if Input.is_action_just_released("shoot"):
		weapon.trigger_released(bullet_origin.global_transform)


func interact(body: Node3D):
	if !can_use:
		return
	if current_user == body:
		leave_mg(body)
	elif current_user == null:
		enter_mg(body)


func enter_mg(body: Node3D):
	body.can_move = false
	body.velocity = Vector3.ZERO
	just_entered=true
	
	yaw = yaw_pivot.rotation.y
	pitch = pitch_pivot.rotation.x
	body.weapon_holder.visible = false
	# emulate ads
	body.aim_changed.emit(true)
	# save last used weapon
	original_weapon_index = body.current_weapon_index
	# connect ammo and sync
	weapon.ammo_changed.connect(body._on_weapon_ammo_changed)
	body._on_weapon_ammo_changed(weapon.current_ammo, weapon.full_ammo)
	# set user
	weapon.wielder = body
	current_user = body
	
	body.camera.position = body.camera_origin
	body.camera_pivot.rotation.z = 0.0
	
	await get_tree().physics_frame
	body.global_position = seat_marker.global_position
	# remove camera pivot from player
	original_camera_pivot_transform = body.camera_pivot.transform
	original_camera_parent = body.camera_pivot.get_parent()
	body.camera_pivot.reparent(camera_position, false)
	body.camera_pivot.transform = Transform3D.IDENTITY


func _on_timer_timeout():
	can_use = true
	print("Sex")


func leave_mg(body: Node3D):
	body.global_position = exit_marker.global_position
	body.weapon_holder.visible = true
	# revert ads
	body.aim_changed.emit(false)
	# disconnect ammo
	weapon.ammo_changed.disconnect(body._on_weapon_ammo_changed)
	# clean up
	weapon.wielder = null
	current_user = null
	
	await get_tree().physics_frame
	# give camera pivot back
	body.camera_pivot.reparent(original_camera_parent, false)
	body.camera_pivot.transform = original_camera_pivot_transform
	# reset pivots
	yaw_pivot.rotation.y = 0.0
	pitch_pivot.rotation.x = 0.0
	yaw = 0.0
	pitch = 0.0
	body.yaw = body.rotation.y
	body.pitch = body.camera_pivot.rotation.x
	body.can_move = true
	# equip last used weapon
	body.equip_weapon(original_weapon_index)
	
