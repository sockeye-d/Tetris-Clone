@tool
class_name OptionsSettingItem extends SettingItem


@export var options: Array[String]:
	set(value):
		options = value

@warning_ignore("unused_private_class_variable")
@export_tool_button("Update enum") var _update_enum_btn = notify_property_list_changed


func _get_type() -> Variant.Type:
	return TYPE_INT


func _get_custom_property() -> Dictionary[String, Variant]:
	return {
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(options),
	}
