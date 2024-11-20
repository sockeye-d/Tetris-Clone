@tool
class_name SceneTransition extends ColorRect


const DEFAULT_TRANS := Tween.TRANS_EXPO
const DEFAULT_EASE_IN := Tween.EASE_IN
const DEFAULT_EASE_OUT := Tween.EASE_OUT
const TRANS_DURATION := 0.75


signal transition_completed


@export_tool_button("Scene transition begin") var __ := transition_begin
@export_tool_button("Scene transition middle") var ___ := transition_middle
@export_tool_button("Scene transition end") var ____ := transition_end


var t: Tween


func transition_begin() -> void:
	if t and t.is_valid():
		t.kill()
	t = create_tween()
	t.set_parallel()
	
	t.tween_callback(show)
	(t.tween_property(self, ^"material:shader_parameter/blur", 7.0, TRANS_DURATION)
		.set_ease(DEFAULT_EASE_IN)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/tint", Vector4(0.0, 0.0, 0.0, 1.0), TRANS_DURATION)
		.set_ease(DEFAULT_EASE_IN)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/zoom", 2.0, TRANS_DURATION)
		.set_ease(DEFAULT_EASE_IN)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/rgb_separation", 0.1, TRANS_DURATION)
		.set_ease(DEFAULT_EASE_IN)
		.set_trans(DEFAULT_TRANS))
	
	t.set_parallel(false)
	t.tween_callback(transition_completed.emit)
	await t.finished


func transition_middle() -> void:
	show()
	material["shader_parameter/blur"] = 7.0
	material["shader_parameter/tint"] = Vector4(0.0, 0.0, 0.0, 1.0)
	material["shader_parameter/zoom"] = 2.0
	material["shader_parameter/rgb_separation"] = 0.1


func transition_end() -> void:
	material["shader_parameter/zoom"] = 0.0
	if t and t.is_valid():
		t.kill()
	t = create_tween()
	t.set_parallel()
	(t.tween_property(self, ^"material:shader_parameter/blur", 0.0, TRANS_DURATION)
		.set_ease(DEFAULT_EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/tint", Vector4(1.0, 1.0, 1.0, 1.0), TRANS_DURATION)
		.set_ease(DEFAULT_EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/zoom", 1.0, TRANS_DURATION)
		.set_ease(DEFAULT_EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	(t.tween_property(self, ^"material:shader_parameter/rgb_separation", 0.0, TRANS_DURATION)
		.set_ease(DEFAULT_EASE_OUT)
		.set_trans(DEFAULT_TRANS))
	
	t.set_parallel(false)
	t.tween_callback(hide)
	t.tween_callback(transition_completed.emit)
	await t.finished


func d(tweener) -> void:
	tweener.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)


class Wrapper:
	var value
	func _init(_value = null) -> void:
		self.value = _value
