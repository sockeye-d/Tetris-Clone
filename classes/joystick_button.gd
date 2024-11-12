@tool
class_name JoystickButton extends Control


@export var action_name: StringName:
	set(value):
		action_name = value
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if ProjectSettings.get("input/" + action_name) == null:
		warnings.append("Action '%s' not found in the InputMap" % action_name)
	
	return warnings


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		var pressed: bool = event.button_mask & MOUSE_BUTTON_MASK_LEFT
		var local_rect := Rect2(Vector2.ZERO, size)
		#print(action_name)
		#print(event.position)
		if pressed and get_global_rect().has_point(event.position):
			Input.action_press(action_name)
		else:
			Input.action_release(action_name)
