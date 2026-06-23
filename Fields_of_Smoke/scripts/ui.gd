extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var current_ammo = $HBoxContainer/CurrentAmmo
@onready var full_ammo = $HBoxContainer/FullAmmo
@onready var blood_screen = $BloodScreen
@onready var hurt_sound = $HurtSound
@onready var crosshair = $Crosshair
#idk így jobb szeretem de ha nem tetszik így átírjuk
@export var hithair: TextureRect

var prev_health: int = 0

func _on_hit():
	hithair.did_hit()

func _on_health_changed(current_health, max_health):
	health_bar.max_value = max_health
	health_bar.value = current_health
	if prev_health == 0:
		prev_health = max_health
	if current_health < prev_health:
		await wounded_effects()
	prev_health = current_health
	

func wounded_effects():
	blood_screen.show_damage()
	hurt_sound.pitch_scale = randf_range(0.95, 1.05)
	hurt_sound.play()


func update_ammo(current, max_ammo):
	print("ui update ammo: ", current, max_ammo)
	current_ammo.text = str(current)
	full_ammo.text = str(max_ammo)
	
	
func update_crosshair(is_ads: bool):
	print("ui update aim: ", is_ads)
	if is_ads:
		crosshair.visible = false
	else:
		crosshair.visible = true
