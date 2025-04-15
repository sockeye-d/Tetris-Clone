@tool
class_name MainGameBackground extends ColorRect


@export var base_color: Color = Color(0.03, 0.03, 0.03)
@export var pulse_color: Color = Color(0.3, 0.3, 0.3)
@export var pulse_decay: float = 5.0

@export var test_pulse_fac: float = 1.0

@warning_ignore("unused_private_class_variable")
@export_tool_button("Test pulse") var test_pulse = func():
	pulse(test_pulse_fac)


var pulse_fac := 0.0


func _process(delta: float) -> void:
	pulse_fac = lerpf(0.0, pulse_fac, exp(-pulse_decay * delta))
	color = base_color.lerp(pulse_color, pulse_fac)


func pulse(strength: float) -> void:
	pulse_fac += strength
