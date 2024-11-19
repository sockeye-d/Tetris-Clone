@tool
class_name ModalTransition extends ColorRect


const DEFAULT_TRANS := Tween.TRANS_EXPO
const TRANS_DURATION := 1.0


signal transition_completed


@export_tool_button("Scene transition begin") var __ := transition_begin
@export_tool_button("Scene transition middle") var ___ := transition_middle
@export_tool_button("Scene transition end") var ____ := transition_end


var t: Tween


func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = preload("res://scenes/main_scene/transition.gdshader")
	# the shader parameter properties don't exist until they are enumerated?????
	material.get_property_list()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func transition_begin() -> void:
	if t and t.is_valid():
		t.kill()
	t = create_tween()
	t.set_parallel()
	
	t.tween_callback(show)
	(t.tween_property(self, ^"material:shader_parameter/blur", 5.0, TRANS_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/rgb_separation", 0.06, TRANS_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/tint", Vector4(0.5, 0.5, 0.5, 1.0), TRANS_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	t.set_parallel(false)
	t.tween_callback(transition_completed.emit)
	await t.finished


func transition_middle() -> void:
	show()
	material["shader_parameter/blur"] = 5.0
	material["shader_parameter/rgb_separation"] = 0.06
	material["shader_parameter/tint"] = Vector4(0.5, 0.5, 0.5, 1.0)


func transition_end() -> void:
	if t and t.is_valid():
		t.kill()
	t = create_tween()
	t.set_parallel()
	(t.tween_property(self, ^"material:shader_parameter/blur", 0.0, TRANS_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/rgb_separation", 0.0, TRANS_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/tint", Vector4.ONE, TRANS_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	t.set_parallel(false)
	t.tween_callback(hide)
	t.tween_callback(transition_completed.emit)
	await t.finished
