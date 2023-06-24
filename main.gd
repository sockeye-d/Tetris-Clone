extends Node2D

@export var GAMEBOARD: TileMap
@export var HALF_BOARD_SIZE: Vector2i = Vector2i(5, 10)
@export var TILE_TO_ATLAS: Dictionary = { 0: Vector2i(3, 0), 1: Vector2i(4, 0)}
@export var DROP_SPEED: float = 0.1

const TETRONIMOES: Dictionary = {
		# I tetronimo
		0: [[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 1, 1, 1, 1],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# J tetronimo
		1: [[0, 0, 0, 0, 0],
			[0, 1, 0, 0, 0],
			[0, 1, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# L tetronimo
		2: [[0, 0, 0, 0, 0],
			[0, 0, 0, 1, 0],
			[0, 1, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# O tetronimo
		3: [[0, 0, 0, 0, 0],
			[0, 0, 1, 1, 0],
			[0, 0, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# S tetronimo
		4: [[0, 0, 0, 0, 0],
			[0, 0, 1, 1, 0],
			[0, 1, 1, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# T tetronimo
		5: [[0, 0, 0, 0, 0],
			[0, 0, 1, 0, 0],
			[0, 1, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# Z tetronimo
		6: [[0, 0, 0, 0, 0],
			[0, 1, 1, 0, 0],
			[0, 0, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
}

const JLSTZ_KICK_OFFSETS: Dictionary = {
		0: [Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0)],
		1: [Vector2i( 0, 0), Vector2i(+1, 0), Vector2i(+1,-1), Vector2i( 0,+2), Vector2i(+1,+2)],
		2: [Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0)],
		3: [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(-1,-1), Vector2i( 0,+2), Vector2i(-1,+2)],
}

const I_KICK_OFFSETS: Dictionary = {
		0: [Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(+2, 0), Vector2i(-1, 0), Vector2i(+2, 0)],
		1: [Vector2i(-1, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0,+1), Vector2i( 0,-2)],
		2: [Vector2i(-1,+1), Vector2i(+1,+1), Vector2i(-2,+1), Vector2i(+1, 0), Vector2i(-2, 0)],
		3: [Vector2i( 0,+1), Vector2i( 0,+1), Vector2i( 0,+1), Vector2i( 0,-1), Vector2i( 0,+2)],
}

const O_KICK_OFFSETS: Dictionary = {
		0: [Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0)],
		1: [Vector2i( 0,-1), Vector2i( 0,-1), Vector2i( 0,-1), Vector2i( 0,-1), Vector2i( 0,-1)],
		2: [Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-1,-1)],
		3: [Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0)],
}

const KICK_OFFSETS: Dictionary = {
		0: I_KICK_OFFSETS,
		1: JLSTZ_KICK_OFFSETS,
		2: JLSTZ_KICK_OFFSETS,
		3: O_KICK_OFFSETS,
		4: JLSTZ_KICK_OFFSETS,
		5: JLSTZ_KICK_OFFSETS,
		6: JLSTZ_KICK_OFFSETS,
}

const Tetronimo = preload("res://tetronimo.gd")

var gameboard_array: Array = []
var gameboard_size: Vector2i

var fall_speed: float

var current_piece: Tetronimo
var current_piece_array: Array
var fall_time: float

func _ready() -> void:
	fall_speed = 0.5
	gameboard_size = HALF_BOARD_SIZE * 2
	GAMEBOARD.clear()
	_construct_gameboard_borders(GAMEBOARD, HALF_BOARD_SIZE)
	_initialize_gameboard_array(gameboard_array, HALF_BOARD_SIZE, func(position: Vector2i):
		return 0 if HALF_BOARD_SIZE.y * 2.0 - position.y > 3 else 1
		)
	$Particles.show()


func _process(delta: float) -> void:
	_process_current_piece(delta)
	var array = gameboard_array
	if not current_piece == null:
		array = _combine_boards(array, current_piece_array)
	GAMEBOARD.clear()
	_construct_gameboard_borders(GAMEBOARD, HALF_BOARD_SIZE)
	_draw_gameboard_to_tileset(array, GAMEBOARD, TILE_TO_ATLAS, HALF_BOARD_SIZE)


func _process_current_piece(delta: float):
	if not current_piece == null:
		$Label.text = str(_piece_size(current_piece))
		fall_time += delta
		if fall_time > (DROP_SPEED if Input.is_action_pressed("drop") else fall_speed):
			fall_time = 0.0
			current_piece.position.y += 1
			current_piece_array = _create_board_from_piece(current_piece, HALF_BOARD_SIZE)
			if _piece_is_colliding_array(current_piece_array, gameboard_array):
				current_piece.position.y -= 1
		if Input.is_action_just_pressed("rotate_left"):
			current_piece.rotate(-1)
			current_piece = _kick(current_piece, posmod(current_piece.rotation + 1, 4), gameboard_array)
		if Input.is_action_just_pressed("rotate_right"):
			current_piece.rotate(1)
			current_piece = _kick(current_piece, posmod(current_piece.rotation - 1, 4), gameboard_array)
		if Input.is_action_just_pressed("hard_drop"):
			current_piece = null
	else:
		current_piece = _create_new_piece(randi() % TETRONIMOES.size())
		fall_time = 0.0
	if current_piece == null:
		_initialize_gameboard_array(current_piece_array, HALF_BOARD_SIZE)
	else:
		current_piece_array = _create_board_from_piece(current_piece, HALF_BOARD_SIZE)


func _construct_gameboard_borders(tilemap: TileMap, half_size: Vector2i):
	# Horizontal borders
	for x in range(half_size.x + 1):
		if not x == half_size.x:
			tilemap.set_cell(0, Vector2i(x, half_size.y), 0, Vector2i(1, 2))
			tilemap.set_cell(0, Vector2i(x, -half_size.y - 1), 0, Vector2i(1, 0))
		tilemap.set_cell(0, Vector2i(-x, half_size.y), 0, Vector2i(1, 2))
		tilemap.set_cell(0, Vector2i(-x, -half_size.y - 1), 0, Vector2i(1, 0))
		
	# Vertical borders
	for y in range(half_size.y + 1):
		if not y == half_size.y:
			tilemap.set_cell(0, Vector2i(half_size.x, y), 0, Vector2i(2, 1))
			tilemap.set_cell(0, Vector2i(-half_size.x - 1, y), 0, Vector2i(0, 1))
		tilemap.set_cell(0, Vector2i(half_size.x, -y), 0, Vector2i(2, 1))
		tilemap.set_cell(0, Vector2i(-half_size.x - 1, -y), 0, Vector2i(0, 1))
	
	# Fill in corners
	tilemap.set_cell(0, Vector2i(-(half_size.x + 1), -(half_size.y + 1)), 0, Vector2i(0, 0))
	tilemap.set_cell(0, Vector2i((half_size.x), -(half_size.y + 1)), 0, Vector2i(2, 0))
	tilemap.set_cell(0, Vector2i((half_size.x), (half_size.y)), 0, Vector2i(2, 2))
	tilemap.set_cell(0, Vector2i(-(half_size.x + 1), (half_size.y)), 0, Vector2i(0, 2))


func _initialize_gameboard_array(array: Array, half_size: Vector2i, data: Callable = func(x):
	return 0) -> Array:
	array.clear()
	for y in range(half_size.y * 2):
		array.append([])
		for x in range(half_size.x * 2):
			array[y].append(data.call(Vector2i(x, y)))
			
	return array


func _print_2d_array(array: Array):
	for i in range(array.size()):
		var current_text = ""
		for j in range(array[i].size()):
			current_text += str(array[i][j]) + " "
		print(current_text)


func _draw_gameboard_to_tileset(array: Array, tilemap: TileMap, tile_dictionary: Dictionary, half_size: Vector2i):
	for y in range(array.size()):
		for x in range(array[y].size()):
			var data = _2d_index(array, Vector2i(x, y))
			tilemap.set_cell(0, Vector2i(x, y) - half_size, 0, tile_dictionary[clamp(array[y][x], 0, 1)])
			if data > 0:
				tilemap.set_cell(1, Vector2i(x, y) - half_size, 0, Vector2i(_get_neighbors(array, Vector2i(x, y), data, false), 4), data + 1)


func _get_neighbors(array: Array, pos: Vector2i, current_data, edge_data: bool) -> int:
	var offset: Vector2i = Vector2i.LEFT
	var res: int = 0
	for r in range(4):
		var current_pos = pos + Vector2i(offset.x, -offset.y)
		var is_edge = current_pos.y >= array.size() or current_pos.y < 0
		if not is_edge:
			is_edge = current_pos.x >= array[current_pos.y].size() or current_pos.x < 0
		var data: bool = edge_data
		if not is_edge:
			data = _2d_index(array, current_pos) == current_data
		res <<= 1
		res |= int(data)
		offset = Vector2i(-offset.y, offset.x)

	return res


func _2d_index(array: Array, pos: Vector2i):
	return array[pos.y][pos.x]


func _rotate_position(vector: Vector2i, size: Vector2i , direction: int) -> Vector2i:
	match direction % 4:
		0:
			return vector
		1:
			return Vector2i(vector.y, size.y - vector.x)
		2:
			return Vector2i(size.x - vector.x, size.y - vector.y)
		3:
			return Vector2i(size.y - vector.y, vector.x)
	return vector


func _rotate_piece(array: Array, direction: int) -> Array:
	if direction == 0:
		return array
	var new_array = array.duplicate(true)
	for y in range(array.size()):
		for x in range(array[y].size()):
			var current_position: Vector2i = Vector2i(x, y)
			var rotated_position: Vector2i = _rotate_position(current_position, Vector2i(array[y].size() - 1, array.size() - 1), direction)
			new_array[current_position.y][current_position.x] = _2d_index(array, rotated_position)
	
	return new_array


func _create_board_from_piece(piece: Tetronimo, half_size: Vector2i) -> Array:
	var array: Array
	_initialize_gameboard_array(array, half_size)
	
	var piece_array: Array = _rotate_piece(TETRONIMOES[piece.type], piece.rotation)
	
	for y in range(piece_array.size()):
		for x in range(piece_array[y].size()):
			var full_position: Vector2i = piece.position + Vector2i(x, y)
			if full_position.x >= 0 and full_position.x <= array[y].size():
				if full_position.y >= 0 and full_position.y < array.size():
					array[full_position.y][full_position.x] = piece.type + 1 if piece_array[y][x] > 0 else 0
	
	return array


func _piece_size(piece: Tetronimo) -> Dictionary:
	var array: Array = _rotate_piece(TETRONIMOES[piece.type], piece.rotation)
	var min: Vector2i = Vector2i(array[0].size(), array.size())
	var max: Vector2i = Vector2i.ZERO
	for y in range(array.size()):
		for x in range(array[y].size()):
			var pos: Vector2i = Vector2i(x, y)
			var data = _2d_index(array, pos)
			if data > 0:
				min.x = min(min.x, pos.x)
				min.y = min(min.y, pos.y)
				max.x = max(max.x, pos.x)
				max.y = max(max.y, pos.y)
	return { "min": min, "max": max, "size": max - min + Vector2i.ONE }


func _piece_is_colliding_array(piece_array: Array, board: Array) -> bool:
	for y in range(board.size()):
		for x in range(board[y].size()):
			var pos = Vector2i(x, y)
			if _2d_index(piece_array, pos) > 0 and _2d_index(board, pos) > 0:
				return true
	return false


func _piece_is_colliding(piece: Tetronimo, board: Array) -> bool:
	return _piece_is_colliding_array(_create_board_from_piece(piece, HALF_BOARD_SIZE), board)


func _combine_boards(array_0: Array, array_1: Array):
	var res: Array
	_initialize_gameboard_array(res, Vector2i(array_0[0].size(), array_0.size()) / 2)
	for y in range(res.size()):
		for x in range(res[y].size()):
			var pos = Vector2i(x, y)
			var data_0 = _2d_index(array_0, pos)
			var data_1 = _2d_index(array_1, pos)
			res[y][x] = data_0 if data_0 > 0 else data_1
	return res


func _kick(piece: Tetronimo, previous_rotation: int, board: Array) -> Tetronimo:
	var previous_kick = KICK_OFFSETS[piece.type][previous_rotation]
	var current_kick = KICK_OFFSETS[piece.type][piece.rotation]
	for x in range(5):
		var kick_offset: Vector2i = previous_kick[x] - current_kick[x]
		var candidate: Tetronimo = Tetronimo.new(piece.type, piece.position + kick_offset, piece.rotation)
		if not _piece_is_colliding(candidate, board):
			return candidate
	return piece


func _create_new_piece(type: int):
	var piece: Tetronimo = Tetronimo.new(type, Vector2i.ZERO, 0)
	var dimensions = _piece_size(piece)
	piece.position.x = HALF_BOARD_SIZE.x - dimensions.min.x - ceil(dimensions.size.x / 2.0)
	piece.position.y = -dimensions.max.y - 1
	return piece
