@tool
class_name Transition extends ColorRect


signal transition_completed


@export_tool_button("Transition begin") var transition_begin_fn := transition_begin
@export_tool_button("Transition middle") var transition_middle_fn := transition_middle
@export_tool_button("Transition end") var transition_end_fn := transition_end

var t: Tween


func transition_begin() -> void:
	if t and t.is_valid():
		t.kill()
	t = create_tween()
	t.set_parallel()
	
	t.tween_callback(show)
	d(t.tween_property(self, ^"material:shader_parameter/blur", 7.0, 1.0))
	d(t.tween_property(self, ^"material:shader_parameter/tint", Vector4(0.0, 0.0, 0.0, 1.0), 1.0))
	d(t.tween_property(self, ^"material:shader_parameter/zoom", 0.0, 1.0))
	d(t.tween_property(self, ^"material:shader_parameter/rgb_separation", 0.1, 1.0))
	t.set_parallel(false)
	t.tween_callback(transition_completed.emit)
	await t.finished


func transition_middle() -> void:
	show()
	material["shader_parameter/blur"] = 7.0
	material["shader_parameter/tint"] = Vector4(0.0, 0.0, 0.0, 1.0)
	material["shader_parameter/zoom"] = 0.0
	material["shader_parameter/rgb_separation"] = 0.1


func transition_end() -> void:
	if t and t.is_valid():
		t.kill()
	t = create_tween()
	t.set_parallel()
	d(t.tween_property(self, ^"material:shader_parameter/blur", 0.0, 1.0))
	d(t.tween_property(self, ^"material:shader_parameter/tint", Vector4(1.0, 1.0, 1.0, 1.0), 1.0))
	material["shader_parameter/zoom"] = 3.0
	d(t.tween_property(self, ^"material:shader_parameter/zoom", 1.0, 1.0))
	d(t.tween_property(self, ^"material:shader_parameter/rgb_separation", 0.0, 1.0))
	t.set_parallel(false)
	t.tween_callback(hide)
	t.tween_callback(transition_completed.emit)
	await t.finished


func d(tweener) -> void:
	tweener.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
