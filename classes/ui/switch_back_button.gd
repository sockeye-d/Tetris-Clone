@tool
class_name SwitchBackButton extends Button


@export var switch_to_first: bool = false


func _ready() -> void:
	if Main:
		pressed.connect(Main.switch_back_to_first if switch_to_first else Main.switch_back)
