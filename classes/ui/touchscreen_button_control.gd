class_name TouchscreenButtonControl extends Control


signal pressed
signal released


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var mouse_pressed: bool = event.button_mask & MOUSE_BUTTON_MASK_LEFT
		if mouse_pressed and get_global_rect().has_point(event.position):
			pressed.emit()
		else:
			released.emit()
