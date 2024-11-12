class_name Tetromino

enum Type {
	I,
	J,
	L,
	O,
	S,
	T,
	Z,
}

var type: Type
var position: Vector2i
var rotation: int

func rotate(direction: int):
	rotation = posmod(rotation + direction, 4)

func _init(_type: Type, _pos: Vector2i, _rot: int):
	type = _type
	position = _pos
	rotation = _rot

func duplicate() -> Tetromino:
	return Tetromino.new(type, position, rotation)
