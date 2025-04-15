@tool
class_name JoystickButton extends TouchscreenButtonControl




@export var action_name: StringName:
	set(value):
		action_name = value
		update_configuration_warnings()

@warning_ignore("unused_private_class_variable")
@export_tool_button("Add haptic feedback node") var _add_haptic_feedback_node := func():
	var hf := HapticFeedbacker.new()
	pressed.connect(hf.vibrate, CONNECT_PERSIST)
	add_child(hf, true)
	hf.owner = owner
	hf.name = "HapticFeedbacker"


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if ProjectSettings.get("input/" + action_name) == null:
		warnings.append("Action '%s' not found in the InputMap" % action_name)
	
	return warnings


func _ready() -> void:
	pressed.connect(func(): Input.action_press(action_name))
	released.connect(func(): Input.action_release(action_name))
