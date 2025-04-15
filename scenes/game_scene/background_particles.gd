@tool
extends GPUParticles2D


@warning_ignore("unused_private_class_variable")
@export_tool_button("Test pulse") var test_pulse = pulse
@export var base_speed_scale := 1.0
@export var base_particle_color := Color(1.0, 1.0, 1.0, 0.04)
@export var pulse_particle_color := Color(1.0, 1.0, 1.0, 0.6)


var target_speed_scale = 1.0


func pulse(strength: float = 4.0) -> void:
	speed_scale += 16.0 * strength
	process_material.color += pulse_particle_color * strength * 0.25
	#var t := create_tween()
	##t.tween_property(self, ^"interp_to_end", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	##t.tween_property(self, ^"interp_to_end", 0.0, 0.0)
	#t.set_parallel(true)
	#t.tween_property(self, ^"speed_scale", 16.0 * strength, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	#t.tween_property(self, ^"process_material:color", base_particle_color.lerp(pulse_particle_color, strength * 0.25), 0.2)
	#t.set_parallel(false)
	#
	#t.tween_property(self, ^"process_material:color", base_particle_color, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	#t.set_parallel(true)
	#t.tween_property(self, ^"speed_scale", 1.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
