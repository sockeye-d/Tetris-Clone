class_name Tetronimo extends Object

var type: int
var position: Vector2i
var rotation: int

func rotate(direction: int):
	rotation = posmod(rotation + direction, 4)

func _init(_type: int, _pos: Vector2i, _rot: int):
	type = _type
	position = _pos
	rotation = _rot
