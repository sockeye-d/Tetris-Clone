extends Camera2D

@export var curve: Curve

var offsets: Dictionary[int, Vector2]
var unique_key: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = Vector2.ZERO
	for offset_key in offsets:
		position += offsets[offset_key]


func move(offset_pos: Vector2, time: float = 1.0, easing_curve: Curve = curve):
	var my_key = unique_key
	offsets.merge({ my_key: Vector2.ZERO })
	unique_key += 1
	var tween := create_tween()
	tween.tween_method(
		func(value: float): 
			var t := value
			offsets[my_key] = offset_pos * easing_curve.sample_baked(t),
		0.0, 1.0, time
	)
	tween.tween_callback(func(): offsets.erase(my_key))
