extends Button


var scn = load("res://scenes/game_scene/game_scene.tscn")


func _pressed() -> void:
	Main.switch_to_scene(load("res://scenes/game_scene/game_scene.tscn"))
	Main.clear_history()
