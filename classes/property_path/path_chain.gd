@tool
class_name PathChain extends Path


@export var paths: Array[Path]


func get_value(from) -> Variant:
	if not paths or null in paths:
		return null
	var v = from
	for path in paths:
		v = path.get_value(v)
		if v == null:
			break
	
	return v


func set_value(from, to) -> void:
	if not paths or null in paths:
		return
	if paths.back() is not PathProperty:
		printerr("Last element of the chain must be a PathProperty for set to work")
		return
	
	var v = from
	for path in paths.slice(0, -1):
		v = path.get_value(v)
		if v == null:
			return
	
	(paths[-1] as PathProperty).set_value(v, to)
