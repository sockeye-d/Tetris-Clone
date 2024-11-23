@tool
class_name BasicContainer extends Container


func _get_minimum_size() -> Vector2:
	var min_size := Vector2.ZERO
	for _child in get_children():
		var child := _child as Control
		if not child:
			continue
		
		min_size = min_size.max(child.get_combined_minimum_size())
	return min_size
