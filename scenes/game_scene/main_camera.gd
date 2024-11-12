extends Camera2D

@export var curve: Curve

var offsets: Dictionary
var unique_key: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = Vector2.ZERO
	for offset_pos in offsets.values():
		position += offset_pos


func move(offset_pos: Vector2, time: float = 1.0, easing_curve: Curve = curve, interval: float = 0.001):
	var my_key = unique_key
	offsets.merge({ my_key: Vector2.ZERO })
	unique_key += 1
	$Timer.start(time)
	while not $Timer.is_stopped():
		var t = 1.0 - $Timer.time_left / $Timer.wait_time
		offsets[my_key] = offset_pos * easing_curve.sample_baked(t)
		await get_tree().process_frame
	offsets.erase(my_key)
