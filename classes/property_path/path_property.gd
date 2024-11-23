@tool
class_name PathProperty extends Path


@export var property_name: StringName


func get_value(from) -> Variant:
	if from == null:
		printerr("from was null")
		return null
	
	return from.get(property_name)


func set_value(from, to) -> void:
	if from == null:
		printerr("from was null")
		return
	from.set(property_name, to)
