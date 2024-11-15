extends TouchscreenButtonControl


func _init() -> void:
	pressed.connect(Main.switch_to_scene.bind(preload("res://scenes/modals/game_pause_menu/game_pause_menu.tscn"), true))
