@tool
class_name SwitchToSceneButton extends Button

@export var target_scene: PackedScene:
	set(value):
		target_scene = value
		notify_property_list_changed()
@export var use_modal: bool
@export var clear_history: bool = false


func _property_can_revert(property: StringName) -> bool:
	if property == "target_scene":
		return true
	if property == "use_modal":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == "target_scene":
		return null
	if property == "use_modal":
		if not (target_scene and target_scene.can_instantiate()):
			return false
		var inst := target_scene.instantiate()
		return inst is Modal
	return null


func _ready() -> void:
	if Main:
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	Main.switch_to_scene(target_scene, use_modal)
