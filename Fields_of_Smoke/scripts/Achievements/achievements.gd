extends Stats

signal achievement_unlocked(title)


func check_achievements(_stat_name, _new_value):
	if is_loading:
		return
	for id in achievements:
		var ach = achievements[id]
		if not ach["unlocked"] and ach["condition"].call():
			ach["unlocked"] = true
			achievement_unlocked.emit(ach["title"])
			print("Achievement feloldva: ", ach["title"])


func _ready() -> void:
	stat_changed.connect(check_achievements)
	achievements = {
		"first_blood": {
			"title": "Első Gyilkosság",
			"description": "Ölj meg 1 ellenséget!",
			"unlocked": false,
			"condition": func(): return stats["kills"] >= 1
		},
		"beni_sex": { # bro we need to unlock this UwU
			"title": "Kiadós szex a legjobbal",
			"description": "Szexelj 100-szor, hogy Benivel is szexelhess!",
			"unlocked": false,
			"condition": func(): return stats["shift"] >= 100
		}
	}
	loadStats()
