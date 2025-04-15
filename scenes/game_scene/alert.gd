@tool
extends Label

@warning_ignore("unused_private_class_variable")
@export_tool_button("Animate", "AnimatedSprite2D") var animate_btn = animate
@export var scale_curve: Curve
@export var modulate_curve: Curve


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	size = get_minimum_size()
	pivot_offset = size * 0.5
	position = -pivot_offset


func animate():
	show()
	scale = Vector2.ONE * 0.0
	modulate.a = 1.0
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 2.0).set_custom_interpolator(func(t): return scale_curve.sample_baked(t))
	#.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_custom_interpolator(func(t): return modulate_curve.sample_baked(t))
	if Engine.is_editor_hint():
		tween.chain().tween_callback(hide)
	else:
		tween.chain().tween_callback(queue_free)
