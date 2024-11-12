@tool
class_name JoystickContainer extends Container


enum Direction {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
}


const DIRECTION_NAME_MAP = {
	"top": Direction.TOP,
	"bottom": Direction.BOTTOM,
	"left": Direction.LEFT,
	"right": Direction.RIGHT,
}


@export var button_controls: Dictionary[Direction, Control]:
	set(value):
		button_controls = value
		update_minimum_size()
		queue_sort()
@export var button_separation: float:
	set(value):
		button_separation = value
		update_minimum_size()
		queue_sort()


func _property_can_revert(property: StringName) -> bool:
	if property == "button_controls":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == &"button_controls":
		var count := get_child_count()
		if count == 0:
			return { }
		var controls: Dictionary[Direction, Control]
		for child_i in count:
			var child := get_child(child_i)
			if child.name.to_lower() in DIRECTION_NAME_MAP:
				controls[DIRECTION_NAME_MAP[child.name.to_lower()]] = child
			elif child_i < Direction.size():
				controls[child_i] = get_child(child_i)
		return controls
	return null


func _get_minimum_size() -> Vector2:
	var min_size := Vector2.ZERO
	var control_minsizes: Dictionary[Direction, Vector2]
	for direction in button_controls.keys():
		if button_controls[direction]:
			control_minsizes[direction] = button_controls[direction].get_combined_minimum_size()
	# y buttons
	if Direction.TOP in control_minsizes:
		min_size.y += maxf(min_size.y, control_minsizes[Direction.TOP].y)
	if Direction.LEFT in control_minsizes or Direction.RIGHT in control_minsizes:
		min_size.y += button_separation + maxf(
			control_minsizes.get(Direction.LEFT, Vector2.ZERO).y,
			control_minsizes.get(Direction.RIGHT, Vector2.ZERO).y
		)
	if Direction.BOTTOM in control_minsizes:
		min_size.y += button_separation + control_minsizes[Direction.BOTTOM].y
	# x buttons
	if Direction.LEFT in control_minsizes:
		min_size.x += maxf(min_size.x, control_minsizes[Direction.LEFT].x)
	if Direction.TOP in control_minsizes or Direction.BOTTOM in control_minsizes:
		min_size.x += button_separation + maxf(
			control_minsizes.get(Direction.TOP, Vector2.ZERO).x,
			control_minsizes.get(Direction.BOTTOM, Vector2.ZERO).x
		)
	if Direction.RIGHT in control_minsizes:
		min_size.x += button_separation + control_minsizes[Direction.RIGHT].x
	
	return min_size

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var top := button_controls.get(Direction.TOP) as Control
		var btm := button_controls.get(Direction.BOTTOM) as Control
		var lft := button_controls.get(Direction.LEFT) as Control
		var rgt := button_controls.get(Direction.RIGHT) as Control
		if top:
			fit_child_in_rect(top, Rect2(
				Vector2((size.x - top.size.x) * 0.5, 0.0),
				top.get_combined_minimum_size()
			))
		if btm:
			fit_child_in_rect(btm, Rect2(
				Vector2((size.x - btm.size.x) * 0.5, size.y - btm.size.y),
				btm.get_combined_minimum_size()
			))
		if lft:
			fit_child_in_rect(lft, Rect2(
				Vector2(0.0, (size.y - lft.size.y) * 0.5),
				lft.get_combined_minimum_size()
			))
		if rgt:
			fit_child_in_rect(rgt, Rect2(
				Vector2(size.x - rgt.size.x, (size.y - rgt.size.y) * 0.5),
				rgt.get_combined_minimum_size()
			))
		
		update_minimum_size()
