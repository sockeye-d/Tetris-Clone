@tool
class_name JoystickButton extends TouchscreenButtonControl


@export var action_name: StringName:
	set(value):
		action_name = value
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if ProjectSettings.get("input/" + action_name) == null:
		warnings.append("Action '%s' not found in the InputMap" % action_name)
	
	return warnings


func _ready() -> void:
	pressed.connect(func(): Input.action_press(action_name))
	released.connect(func(): Input.action_release(action_name))
