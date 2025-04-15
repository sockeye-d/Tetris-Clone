@tool
class_name Path extends Resource

func get_value(_from) -> Variant:
	push_error("hey you're not supposed to be here")
	return null


func set_value(_from, _to) -> void:
	push_error("hey you're not supposed to be here")
