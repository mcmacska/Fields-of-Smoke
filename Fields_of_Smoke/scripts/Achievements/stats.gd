extends Node
class_name Stats

signal stat_changed(stat_name, new_value)

const SAVE_PATH = "user://game_data.json"

var is_loading = true
var achievements = {}
var stats = {
	"kills": 0,
	"deaths": 0,
	"shift": 0,
	"miss": 0,
	"hit": 0,
	"shot": 0
}

func saveStats():
	var save_dict = {
		"stats": stats,
		"achievements": {}
	}
	for id in achievements:
		save_dict["achievements"][id] = achievements[id]["unlocked"]
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))


func loadStats():
	is_loading = true
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data = json.data
		if "stats" in data:
			stats = data["stats"]
		if "achievements" in data:
			for id in data["achievements"]:
				if achievements.has(id):
					achievements[id]["unlocked"] = data["achievements"][id]
	is_loading = false


func increment_stat(stat_name: String, amount: int = 1):
	if stats.has(stat_name):
		stats[stat_name] += amount
		stat_changed.emit(stat_name, stats[stat_name])
		
		if stat_name == "shot" or stat_name == "hit":
			var new_miss = max(0, stats["shot"] - stats["hit"])
			if stats["miss"] != new_miss:
				stats["miss"] = new_miss
				stat_changed.emit("miss", stats["miss"])
		
		saveStats()
