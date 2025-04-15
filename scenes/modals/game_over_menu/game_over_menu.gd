extends Modal

@onready var left_container: VBoxContainer = %LeftContainer
@onready var right_container: VBoxContainer = %RightContainer


func _ready() -> void:
	add_data({
		"lines cleared": str(GameInfo.lines_cleared),
		#"score": str(GameInfo.score),
	})


func add_data(data: Dictionary[String, String]) -> void:
	for n in left_container.get_children():
		n.queue_free()
	
	for n in right_container.get_children():
		n.queue_free()
	
	for data_key in data:
		var data_val := data[data_key]
		var key_label := Label.new()
		key_label.text  = data_key
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		key_label.size_flags_horizontal = Control.SIZE_EXPAND
		var val_label := Label.new()
		val_label.text  = data_val
		val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		val_label.size_flags_horizontal = Control.SIZE_EXPAND
		
		left_container.add_child(key_label)
		right_container.add_child(val_label)
