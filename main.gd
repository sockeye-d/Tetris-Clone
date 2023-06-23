extends Node2D

@export var GAMEBOARD: TileMap
@export var HALF_BOARD_SIZE: Vector2i
@export var TILE_TO_ATLAS: Dictionary

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

var gameboard_array: Array = []
var gameboard_size: Vector2i

const Tetronimo = preload("res://tetronimo.gd")

var current_piece: PieceData


func _ready() -> void:
	gameboard_size = HALF_BOARD_SIZE * 2
	GAMEBOARD.clear()
	_construct_gameboard_borders(GAMEBOARD, HALF_BOARD_SIZE)
	_initialize_gameboard_array(gameboard_array, HALF_BOARD_SIZE, func(position: Vector2i):
		return 0 if randf() < 0.5 else 1
		)
	_print_2d_array(TETRONIMOES[0])


func _process(delta: float) -> void:
	GAMEBOARD.clear()
	_construct_gameboard_borders(GAMEBOARD, HALF_BOARD_SIZE)
	gameboard_array = _create_board_from_piece(Tetronimo(), HALF_BOARD_SIZE)
	_draw_gameboard_to_tileset(gameboard_array, GAMEBOARD, TILE_TO_ATLAS, HALF_BOARD_SIZE)


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
			tilemap.set_cell(0, Vector2i(x, y) - half_size, 0, tile_dictionary[array[y][x]])
			if _2d_index(array, Vector2i(x, y)) > 0:
				tilemap.set_cell(1, Vector2i(x, y) - half_size, 0, Vector2i(_get_neighbors(array, Vector2i(x, y), false), 4))


func _get_neighbors(array: Array, pos: Vector2i, edge_data: bool) -> int:
	var offset: Vector2i = Vector2i.LEFT
	var res: int = 0
	for r in range(4):
		var current_pos = pos + Vector2i(offset.x, -offset.y)
		var is_edge = current_pos.y >= array.size() or current_pos.y < 0
		if not is_edge:
			is_edge = current_pos.x >= array[current_pos.y].size() or current_pos.x < 0
		var data: bool = edge_data
		if not is_edge:
			data = _2d_index(array, current_pos) > 0
		res <<= 1
		res |= int(data)
		offset = Vector2i(-offset.y, offset.x)

	return res


func _2d_index(array: Array, pos: Vector2i):
	return array[pos.y][pos.x]


func _create_board_from_piece(piece: Tetronimo, half_size: Vector2i) -> Array:
	var array: Array
	_initialize_gameboard_array(array, half_size)
	
	var piece_array: Array = TETRONIMOES[piece.type]
	
	for y in range(piece_array.size()):
		for x in range(piece_array[y].size()):
			var full_position: Vector2i = piece.position + Vector2i(x, y)
			array[full_position.y][full_position.x] = piece_array[y][x]
	
	return array
