@tool
class_name NestedSettingItem extends SettingItem


func _get_type() -> Variant.Type:
	return TYPE_DICTIONARY


func _get_custom_property() -> Dictionary:
	return {
		"hint": PROPERTY_HINT_DICTIONARY_TYPE,
		"hint_string": "%d:;%d/%d:SettingItem" % [TYPE_STRING, TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE],
	}
