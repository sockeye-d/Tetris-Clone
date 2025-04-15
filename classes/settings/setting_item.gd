@tool
class_name SettingItem extends Resource


@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NONE) var setting_value


func _get_property_list() -> Array[Dictionary]:
	var p: Array[Dictionary]
	if _get_type() != TYPE_NIL:
		p.append({
			"name": "setting_value",
			"class_name": &"",
			"type": _get_type(),
			"hint": PROPERTY_HINT_NONE,
			"usage": PROPERTY_USAGE_EDITOR
		}.merged(_get_custom_property(), true))
	return p


func _get_type() -> Variant.Type:
	return TYPE_NIL


func _get_custom_property() -> Dictionary[String, Variant]:
	return { }
