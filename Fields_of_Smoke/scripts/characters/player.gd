extends CharacterBody3D

@export var sensitivity: float = 0.003
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera
var pitch: float = 0.0
var yaw: float = 0.0

# camera recoil effect
var recoil: float = 0.0
var recoil_target: float = 0.0
@export var recoil_vertical: float = 0.01
@export var recoil_horizontal: float = 0.01
var recoil_yaw := 0.0
var recoil_yaw_target := 0.0


const AIR_ACCEL: float = 0.8

var is_running: bool = false
#totally not a ben10 reference
const xlr8: float = 0.2
const BASE_SPEED: float = 10.0
@export var speed_changer: float = 1.0
var internal_speed_changer: float = 1.0
const JUMP_VELOCITY: float = 4.5
var fall_speed: float = 0.0
var fall_damage: int = 0
const SAFE_FALL_SPEED: int = -10
const FALL_DAMAGE_MULTIPLIER: int = -5


@onready var health = $Health
@onready var hitbox = $Hitbox

var is_dead = false
signal died()

# weapon management
var inventory: Array = [null, null, null, null]
var current_weapon_index := 0
var last_weapon_index := 0
var current_weapon: Node = null
var ads: bool = false
@onready var weapon_holder: Node3D = $WeaponHolder
signal ammo_changed(current, max)
signal aim_changed(is_ads)
signal hit()

# camera movement effects
const BOB_FREQ: float = 1.5
var BOB_AMP: float = 0.02
var bob_time: float = 0.0
var camera_origin: Vector3 = Vector3.ZERO
var horizontal_speed: float = 0.0
var target_offset: Vector3 = Vector3.ZERO
var moving_on_floor: bool = false
var bob_phase: float = 0.0
var lean_amount: float = 0.02
var lean_speed: float = 0.05

func _on_hit():
	hit.emit()

func _on_died():
	is_dead = true
	died.emit()
	set_process(false)
	set_physics_process(false)

func _ready():
	# overwrite initial health
	health.max_health = 1000
	health.health = 1000
	health.died.connect(_on_died)
	# add starter weapons
	add_weapon(preload("res://scenes/weapons/weapon.tscn"))
	add_weapon(preload("res://scenes/weapons/smg62.tscn"))
	equip_weapon(0)
	# set camera origin
	camera_origin = camera.position
	# set weapon position
	current_weapon.position = current_weapon.hip_position


func _input(event):
	if is_dead || get_tree().paused:
		return
	if event is InputEventMouseMotion:
		manage_direction(event)
	elif event.is_action_pressed("scroll_up"):
		var next = (current_weapon_index + 1) % inventory.size()
		equip_weapon(next)
	elif event.is_action_pressed("scroll_down"):
		var prev = (current_weapon_index - 1 + inventory.size()) % inventory.size()
		equip_weapon(prev)


func _process(delta):
	if get_tree().paused:
		return
	# handle shooting
	if Input.is_action_pressed("shoot"):
		current_weapon.trigger_held(camera.global_transform)
	if Input.is_action_just_pressed("shoot"):
		current_weapon.trigger_pressed(camera.global_transform)
	if Input.is_action_just_released("shoot"):
		current_weapon.trigger_released(camera.global_transform)
	# aim down sight
	var target = current_weapon.hip_position
	if Input.is_action_just_pressed("ADS"):
		ads = true
		current_weapon.is_ads = ads
		weapon_holder.is_ads = ads
		aim_changed.emit(ads)
	if Input.is_action_just_released("ADS"):
		ads = false
		current_weapon.is_ads = ads
		weapon_holder.is_ads = ads
		aim_changed.emit(ads)
	# switch last item in inventory
	#if Input.is_action_just_released("last_slot") && last_weapon_index != current_weapon_index:
		#equip_weapon(last_weapon_index)
	# 
	if Input.is_action_just_pressed("reload"):
		current_weapon.reload()
	if Input.is_action_just_pressed("run"):
		internal_speed_changer = 2
	if Input.is_action_just_released("run"):
		internal_speed_changer = 1
	# recoil vertical
	recoil = lerp(recoil, recoil_target, 10.0 * delta)
	recoil_target = lerp(recoil_target, 0.0, 5.0 * delta)
	camera_pivot.rotation.x = pitch + recoil
	# recoil horizontal
	recoil_yaw = lerp(recoil_yaw, recoil_yaw_target, 12.0 * delta)
	recoil_yaw_target = lerp(recoil_yaw_target, 0.0, 4.0 * delta)
	rotation.y = yaw + recoil_yaw


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	manage_gravity(delta)
	manage_movement()
	move_and_slide()
	add_movement_effects(delta)


func manage_direction(event):
	 # LEFT / RIGHT (yaw)
	yaw -= event.relative.x * sensitivity
	# UP / DOWN (pitch)
	pitch -= event.relative.y * sensitivity
	pitch = clamp(pitch, -1.5, 1.5)
	

func manage_gravity(delta: float):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta #szerintem egy 1.5 szorzóval jobb
		# track fastest downward speed
		if velocity.y < fall_speed:
			fall_speed = velocity.y
	else:
		# just landed
		if fall_speed < SAFE_FALL_SPEED:
			fall_damage = int(fall_speed - SAFE_FALL_SPEED) * FALL_DAMAGE_MULTIPLIER
			health.take_damage(fall_damage)
		# reset for next jump/fall
		fall_speed = 0.0
		if velocity.y < 0:
			velocity.y = 0


func manage_movement():
	var input_dir = Input.get_vector("left", "right", "backwards", "forward")
	var direction = Vector3.ZERO
	
	# get forward and right directions from player
	var forward = -transform.basis.z
	var right = transform.basis.x
	
	direction = (right * input_dir.x + forward * input_dir.y).normalized()
	
	var ads_multiplier = 1
	if ads:
		ads_multiplier = 0.5
	
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * BASE_SPEED * internal_speed_changer * speed_changer * ads_multiplier, xlr8)
		velocity.z = lerp(velocity.z, direction.z * BASE_SPEED * internal_speed_changer * speed_changer * ads_multiplier, xlr8)
	else:
		velocity.x = direction.x * BASE_SPEED * speed_changer
		velocity.z = direction.z * BASE_SPEED * speed_changer
	
	var target_tilt = -input_dir.x * lean_amount
	camera_pivot.rotation.z = lerp(camera_pivot.rotation.z, target_tilt, lean_speed)
	
	# Handle jump
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VELOCITY


func apply_speed_changer(multiplier: float):
	speed_changer = multiplier
	

func add_weapon(weapon_scene: PackedScene):
	print("add_weapon")
	var weapon = weapon_scene.instantiate()
	var slot = weapon.item_slot
	print("slot: ", slot)
	if inventory[slot] != null:
		inventory[slot].queue_free()
	inventory[slot] = weapon
	weapon.hide()  # don't show yet
	weapon_holder.add_child(weapon)
	# Connect weapon ammo change
	weapon.ammo_changed.connect(_on_weapon_ammo_changed)


func equip_weapon(index: int):
	print("current_weapon_index: ", current_weapon_index)
	print("last_weapon_index: ", last_weapon_index)
	var new_weapon = inventory[index]
	if !new_weapon:
		return

	if current_weapon:
		current_weapon.cancel_reload()
		current_weapon.hide()
		current_weapon.is_ads = false
		aim_changed.emit(false)
	# Spawn new weapon
	current_weapon = new_weapon
	last_weapon_index = current_weapon_index # save last index
	current_weapon_index = index
	current_weapon.show()
	# set wielder
	current_weapon.wielder = self
	# Sync
	_on_weapon_ammo_changed(
		current_weapon.current_ammo,
		current_weapon.full_ammo
	)


func _on_weapon_ammo_changed(current_, max_):
	print("ammo changed: ", current_, max_)
	ammo_changed.emit(current_, max_)

	
func sync_ammo():
	if current_weapon:
		ammo_changed.emit(current_weapon.current_ammo, current_weapon.full_ammo)


#func aim_down_sights(delta):
	#if !current_weapon:
		#return;
		#
	#print("weapon.position:", current_weapon.position)
	#print("weapon.global_position:", current_weapon.global_position)
	#current_weapon.position = current_weapon.position.lerp(
		#current_weapon.ads_position,
		#delta * 10.0
	#)
	#
	#
#func aim_hip(delta):
	#if !current_weapon:
		#return;
		#
	##var target_position: Vector3 = current_weapon.hip_position
	#current_weapon.position = current_weapon.position.lerp(
		#current_weapon.hip_position,
		#delta * 10.0
	#)


func add_movement_effects(delta: float):
	horizontal_speed = sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
	target_offset = Vector3.ZERO # reset the camera offset every frame
	
	moving_on_floor = horizontal_speed > 0.1 and is_on_floor()
	bob_phase = bob_time * BOB_FREQ
	
	if moving_on_floor:
		bob_time += delta * horizontal_speed
	else:
		bob_time = 0.0

	if ads:
		BOB_AMP = 0.002
	else:
		BOB_AMP = 0.02
	# generate the actual bobbing motion
	if moving_on_floor:
		target_offset.y = sin(bob_phase) * BOB_AMP
		# add side-to-side motion
		target_offset.x = cos(bob_phase * 0.5) * BOB_AMP * 0.5

	# smoothly move the camera toward the desired position
	camera.position = camera.position.lerp(
		camera_origin + target_offset,
		delta * 10.0
	)


func add_recoil_effect():
	recoil_target += recoil_vertical
	# horizontal kick
	recoil_yaw_target += randf_range(-recoil_horizontal, recoil_horizontal)
	
