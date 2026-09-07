extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var current_ammo = $HBoxContainer/CurrentAmmo
@onready var full_ammo = $HBoxContainer/FullAmmo
@onready var blood_screen = $BloodScreen
@onready var hurt_sound = $HurtSound
@onready var crosshair = $Crosshair
@onready var interact_text = $Crosshair/InteractText
@onready var ach_text = $AchievementText
#idk így jobb szeretem de ha nem tetszik így átírjuk
@export var hithair: TextureRect

var prev_health: int = 0
var interact_tween: Tween
var ach_tween: Tween

var interactable: Interactable:
	set(value):
		if interactable == value:
			return
		
		interactable = value
		if interactable == null:
			_animate_interact_text(false)
			return
		
		var key = "E"
		for event in InputMap.action_get_events("use"):
			if event is InputEventKey:
				key = OS.get_keycode_string(event.physical_keycode).to_upper()
		interact_text.text = "Press \"" + key + "\" to interact with " + interactable.Name
		_animate_interact_text(true)

func _ready() -> void:
	interact_text.modulate.a = 0.0
	ach_text.modulate.a = 0.0
	var player = owner if owner is CharacterBody3D else get_parent().get_parent().get_parent()
	
	if player and player.has_signal("interactable_focused"):
		player.interactable_focused.connect(on_player_interactable)
	
	if Achievements:
		Achievements.achievement_unlocked.connect(on_achievement_unlocked)


func on_player_interactable(new_interactable: Interactable):
	self.interactable = new_interactable

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
	#print("ui update ammo: ", current, max_ammo)
	current_ammo.text = str(current)
	full_ammo.text = str(max_ammo)


func update_crosshair(is_ads: bool):
	if is_ads:
		crosshair.visible = false
	else:
		crosshair.visible = true

func _animate_interact_text(show_text: bool) -> void:
	if interact_tween and interact_tween.is_running():
		interact_tween.kill()
		
	interact_tween = create_tween().set_parallel(true)
	
	if show_text:
		interact_tween.tween_property(interact_text, "modulate:a", 1.0, 0.2)
	else:
		interact_tween.tween_property(interact_text, "modulate:a", 0.0, 0.15)


func on_achievement_unlocked(title: String, _id: String = "") -> void:
	ach_text.text = "Achievement Unlocked:\n" + title
	
	if ach_tween and ach_tween.is_running():
		ach_tween.kill()
		
	ach_tween = create_tween()
	
	ach_text.modulate.a = 0.0
	ach_text.position.y = -50
	
	#on
	ach_tween.set_parallel(true)
	ach_tween.tween_property(ach_text, "modulate:a", 1.0, 0.4)
	ach_tween.tween_property(ach_text, "position:y", 20.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# wait
	ach_tween.chain().tween_interval(5.0)
	
	# off
	ach_tween.chain().tween_property(ach_text, "modulate:a", 0.0, 0.5)
	ach_tween.parallel().tween_property(ach_text, "position:y", -70.0, 0.5)
