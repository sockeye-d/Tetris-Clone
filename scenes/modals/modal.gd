class_name Modal extends Control


var t: Tween


func _init() -> void:
	modulate.a = 0.0


func transition_in():
	position.y += 30.0
	t = create_tween()
	t.set_parallel()
	t.tween_property(self, ^"position:y", -30.0, 0.5).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, ^"modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func transition_out():
	t = create_tween()
	t.set_parallel()
	t.tween_property(self, ^"position:y", 30.0, 0.5).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, ^"modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
