@tool
class_name MainCamera extends Camera2D

@warning_ignore("unused_private_class_variable")
@export_tool_button("bounce") var test := func():
	move(Vector2(0.0, -30.0), 1.0)

var offsets: Dictionary[StringName, Vector2]
var unique_key: int = 0


func _process(_delta):
	offset = Vector2.ZERO
	for offset_key in offsets:
		offset += offsets[offset_key]


func move(offset_pos: Vector2, time: float = 1.0):
	var my_key := StringName(str(unique_key))
	unique_key += 1
	offsets[my_key] = offset_pos
	var tween := create_tween()
	tween.tween_property(self, "offsets:" + str(my_key), Vector2.ZERO, time).set_custom_interpolator(ease_elastic)
	tween.tween_callback(func(): offsets.erase(my_key))


func ease_elastic(t: float) -> float:
	return 1.0 - cos(5 * PI  * t) * pow(1.0 - t, 3.0)
