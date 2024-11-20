@tool
class_name TouchscreenButtonControl extends TextureRect


signal pressed
signal released


@export var unpressed_texture: Texture2D:
	set(value):
		unpressed_texture = value
		if Engine.is_editor_hint():
			texture = unpressed_texture
@export var pressed_texture: Texture2D
var hitbox: ReferenceRect
@export var show_hitbox: bool:
	set(value):
		show_hitbox = value
		if show_hitbox:
			hitbox = ReferenceRect.new()
			hitbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			add_child(hitbox)
		else:
			hitbox.queue_free()
@export var consume_input: bool = false


var previous_state: bool = false


func _property_can_revert(property: StringName) -> bool:
	if property == "process_mode":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == "process_mode":
		return PROCESS_MODE_ALWAYS
	return null


func _unhandled_input(_event: InputEvent) -> void:
	if _event is InputEventMouse:
		var event := _event as InputEventMouse
		var mouse_pressed: bool = event.button_mask & MOUSE_BUTTON_MASK_LEFT
		var state := mouse_pressed and get_global_rect().has_point(event.position)
		if state == previous_state:
			return
		
		if state:
			texture = pressed_texture
			pressed.emit()
			if consume_input:
				accept_event()
		else:
			texture = unpressed_texture
			released.emit()
			if consume_input:
				accept_event()
		previous_state = state
