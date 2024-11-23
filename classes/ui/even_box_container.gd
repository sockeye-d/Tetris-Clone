@tool
class_name EvenBoxContainer extends BoxContainer


func _notification(what: int) -> void:
	if what == NOTIFICATION_PRE_SORT_CHILDREN:
		var min_size: Vector2 = Vector2.ZERO
		var max_child_size: Vector2 = Vector2.ZERO
		var child_count: int = 0
		for _child in get_children():
			if _child is not Control:
				continue
			var child := _child as Control
			
			min_size = min_size.min(child.get_combined_minimum_size())
			max_child_size = max_child_size.max(child.get_combined_minimum_size())
			
			child_count += 1
		
		var real_min_size: Vector2
		if vertical:
			real_min_size = Vector2(min_size.x, max_child_size.y * child_count + get_theme_constant(&"separation") * (child_count - 1))
		else:
			real_min_size = Vector2(max_child_size.x * child_count + get_theme_constant(&"separation") * (child_count - 1), min_size.y)
		
		custom_minimum_size = real_min_size
