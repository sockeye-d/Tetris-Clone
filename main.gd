extends Node2D

signal death

@export var GAMEBOARD: TileMap
@export var HALF_BOARD_SIZE: Vector2i = Vector2i(5, 10)
@export var TILE_TO_ATLAS: Dictionary = { 0: Vector2i(3, 0), 1: Vector2i(4, 0)}
@export var BASE_DROP_SPEED: float = 0.1
@export var FALL_LOCK_MAX: int = 1
@export var MOVE_INTERVAL: float = 0.05
@export var LINE_CLEAR_EFFECT: PackedScene
@export var SHOW_GHOST_BLOCK: bool = true

const Tetromino = preload("res://tetromino.gd")

const TETROMINOES: Dictionary = {
		# I tetromino
		0: [[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 1, 1, 1, 1],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# J tetromino
		1: [[0, 0, 0, 0, 0],
			[0, 1, 0, 0, 0],
			[0, 1, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# L tetromino
		2: [[0, 0, 0, 0, 0],
			[0, 0, 0, 1, 0],
			[0, 1, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# O tetromino
		3: [[0, 0, 0, 0, 0],
			[0, 0, 1, 1, 0],
			[0, 0, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# S tetromino
		4: [[0, 0, 0, 0, 0],
			[0, 0, 1, 1, 0],
			[0, 1, 1, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# T tetromino
		5: [[0, 0, 0, 0, 0],
			[0, 0, 1, 0, 0],
			[0, 1, 1, 1, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0]],
		# Z tetromino
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

var old_hash: int
var old_gameboard: Array
var old_ghost: Array
var old_bag_piece: int
var old_hold: int

var gameboard_array: Array = []
var gameboard_size: Vector2i

var lines_cleared: int
var pieces_placed: int

var bag: Array
var hold: int
var not_held: bool

var fall_time: float
var fall_speed: float
var fall_lock: int

var current_piece: Tetromino
var current_piece_array: Array

var move_time: float

var label_offsets: Dictionary = {}

func _ready() -> void:
	$Particles.show()
	
	fall_speed = _get_speed()
	gameboard_size = HALF_BOARD_SIZE * 2
	
	_reset_game()
	
	_position_text($LinesCleared, Vector2(-1, -1), Vector2(1, -1))
	_position_text($Next, Vector2(1, -1), Vector2(1, -1))
	_position_text($Hold, Vector2(1, -1), Vector2(1, -5))
	_construct_gameboard_borders(GAMEBOARD, 10, HALF_BOARD_SIZE)

func _process(delta: float) -> void:
	_process_current_piece(delta)
	var array = gameboard_array
	if not current_piece == null:
		array = _combine_boards(array, current_piece_array)
	if not (str(array) + str(hold)).hash() == old_hash:
		_draw_gameboard_to_tileset(array, GAMEBOARD, TILE_TO_ATLAS, HALF_BOARD_SIZE, SHOW_GHOST_BLOCK, current_piece, gameboard_array)
		_draw_piece(bag[0], old_bag_piece, Vector2i(HALF_BOARD_SIZE.x + 1, -HALF_BOARD_SIZE.y + 2), GAMEBOARD)
		
		if hold > -1:
			_draw_piece(hold, old_hold, Vector2i(HALF_BOARD_SIZE.x + 1, -HALF_BOARD_SIZE.y + 7), GAMEBOARD)
		
		old_hash = (str(array) + str(hold)).hash()
		old_bag_piece = bag[0]
		old_hold = hold
	
	$LinesCleared.text = "lines" + "\n" + str(lines_cleared)


func _process_current_piece(delta: float):
	if not current_piece == null:
		fall_time += delta
		move_time += delta
		var drop_speed = min(fall_speed / 2, BASE_DROP_SPEED)
		if fall_time > (drop_speed if Input.is_action_pressed("drop") else fall_speed):
			fall_time = 0.0
			current_piece.position.y += 1
			if _piece_is_colliding(current_piece, gameboard_array):
				current_piece.position.y -= 1
				fall_lock += 1
				if fall_lock > FALL_LOCK_MAX:
					_lock_piece()
			else:
				fall_lock = 0
		if not current_piece == null:
			if Input.is_action_just_pressed("rotate_left") and not current_piece.type == 3:
				current_piece.rotate(-1)
				var candidate = _kick(current_piece, posmod(current_piece.rotation + 1, 4), gameboard_array)
				if candidate == null:
					current_piece.rotate(1)
				else:
					current_piece = candidate
			
			if Input.is_action_just_pressed("rotate_right") and not current_piece.type == 3:
				current_piece.rotate(1)
				var candidate = _kick(current_piece, posmod(current_piece.rotation - 1, 4), gameboard_array)
				if candidate == null:
					current_piece.rotate(-1)
				else:
					current_piece = candidate
			
			var move_axis = Input.get_axis("move_left", "move_right")
			
			if move_axis and move_time > MOVE_INTERVAL:
				current_piece.position.x += move_axis
				if _piece_is_colliding(current_piece, gameboard_array, true):
					current_piece.position.x -= move_axis
				else:
					move_time = 0.0
			
			if Input.is_action_just_pressed("hard_drop"):
				current_piece = _hard_drop(current_piece, gameboard_array)
				_lock_piece()
			
			if Input.is_action_just_pressed("hold") and not_held:
				if not hold == -1:
					bag.insert(0, hold)
				hold = current_piece.type
				_new_game_piece()
				not_held = false
	else:
		_new_game_piece()
	
	if current_piece == null:
		_initialize_gameboard_array(current_piece_array, HALF_BOARD_SIZE)
	else:
		current_piece_array = _create_board_from_piece(current_piece, HALF_BOARD_SIZE)


func _construct_gameboard_borders(tilemap: TileMap, layer: int, half_size: Vector2i):
	# Horizontal borders
	for x in range(half_size.x + 1):
		if not x == half_size.x:
			tilemap.set_cell(layer, Vector2i(x, half_size.y), 0, Vector2i(1, 2))
			tilemap.set_cell(layer, Vector2i(x, -half_size.y - 1), 0, Vector2i(1, 0))
		tilemap.set_cell(layer, Vector2i(-x, half_size.y), 0, Vector2i(1, 2))
		tilemap.set_cell(layer, Vector2i(-x, -half_size.y - 1), 0, Vector2i(1, 0))
		
	# Vertical borders
	for y in range(half_size.y + 1):
		if not y == half_size.y:
			tilemap.set_cell(layer, Vector2i(half_size.x, y), 0, Vector2i(2, 1))
			tilemap.set_cell(layer, Vector2i(-half_size.x - 1, y), 0, Vector2i(0, 1))
		tilemap.set_cell(layer, Vector2i(half_size.x, -y), 0, Vector2i(2, 1))
		tilemap.set_cell(layer, Vector2i(-half_size.x - 1, -y), 0, Vector2i(0, 1))
	
	# Fill in corners
	tilemap.set_cell(layer, Vector2i(-(half_size.x + 1), -(half_size.y + 1)), 0, Vector2i(0, 0))
	tilemap.set_cell(layer, Vector2i((half_size.x), -(half_size.y + 1)), 0, Vector2i(2, 0))
	tilemap.set_cell(layer, Vector2i((half_size.x), (half_size.y)), 0, Vector2i(2, 2))
	tilemap.set_cell(layer, Vector2i(-(half_size.x + 1), (half_size.y)), 0, Vector2i(0, 2))


func _initialize_gameboard_array(array: Array, half_size: Vector2i, data: Callable = func(x):
	return 0) -> Array:
	array.clear()
	for y in range(half_size.y * 2):
		array.append([])
		for x in range(half_size.x * 2):
			array[y].append(data.call(Vector2i(x, y)))
			
	return array


func _print_2d_array(array: Array) -> String:
	var currenter_text = ""
	for i in range(array.size()):
		var current_text = ""
		for j in range(array[i].size()):
			current_text += str(array[i][j]) + " "
		currenter_text += current_text + "\n"
	return currenter_text


func _draw_gameboard_to_tileset(e_array: Array, tilemap: TileMap, tile_dictionary: Dictionary, half_size: Vector2i, draw_ghost: bool, ghost_piece: Tetromino, array_no_piece: Array):
	var array: Array  = e_array.duplicate(true)
	var ghost_array = null
	if draw_ghost and not ghost_piece == null:
		array = _combine_boards(array, _create_board_from_piece(_hard_drop(ghost_piece, array_no_piece), half_size, 7))
	var layers: Array = []
	var delete: Array = []
	for i in range(TETROMINOES.size() + 2):
		layers.append([])
		delete.append([])
	for y in range(array.size()):
		for x in range(array[y].size()):
			var old_board_value = _2d_index(old_gameboard, Vector2i(x, y))
			var new_board_value = _2d_index(array, Vector2i(x, y))
			if not old_board_value == new_board_value:
				layers[_2d_index(array, Vector2i(x, y))].append(Vector2i(x, y) - half_size)
#				if new_board_value == 0 or old_board_value == 8:
				delete[old_board_value].append(Vector2i(x, y) - half_size)
			if _2d_index(array, Vector2i(x, y)) == 0:
				tilemap.set_cell(9, Vector2i(x, y) - half_size, 0, Vector2i(3, 0))
			else:
				tilemap.set_cell(9, Vector2i(x, y) - half_size)
	$Label.text = _print_2d_array(array)
	for i in range(delete.size()):
		tilemap.set_cells_terrain_connect(i, delete[i], 0, -1, false)
	for i in range(layers.size()):
		tilemap.set_cells_terrain_connect(i, layers[i], 0, 0, true)
	old_gameboard = array.duplicate(true)
	return


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


func _create_board_from_piece(piece: Tetromino, half_size: Vector2i, e_data: int = -1) -> Array:
	var data = e_data
	if e_data == -1:
		data = piece.type
	var array: Array
	_initialize_gameboard_array(array, half_size)
	
	var piece_array: Array = _rotate_piece(TETROMINOES[piece.type], piece.rotation)
	
	for y in range(piece_array.size()):
		for x in range(piece_array[y].size()):
			var full_position: Vector2i = piece.position + Vector2i(x, y)
			if full_position.x >= 0 and full_position.x < array[y].size():
				if full_position.y >= 0 and full_position.y < array.size():
					array[full_position.y][full_position.x] = data + 1 if piece_array[y][x] > 0 else 0
	
	return array


func _piece_size(piece: Tetromino) -> Dictionary:
	var array: Array = _rotate_piece(TETROMINOES[piece.type], piece.rotation)
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
			if _2d_index(board, pos) > 0:
				if _2d_index(piece_array, pos) > 0:
					return true
	return false


func _piece_is_colliding(piece: Tetromino, board: Array, edges_collide: bool = true) -> bool:
	if edges_collide:
		var piece_size = _piece_size(piece)
		var piece_min = piece.position + piece_size.min
		var piece_max = piece.position + piece_size.max
		
		if piece_min.x < 0 or piece_max.x > board[0].size() - 1:
			return true
		
		if piece_max.y > board.size() - 1:
			return true
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


func _kick(piece: Tetromino, previous_rotation: int, board: Array) -> Tetromino:
	var previous_kick = KICK_OFFSETS[piece.type][previous_rotation]
	var current_kick = KICK_OFFSETS[piece.type][piece.rotation]
	for x in range(5):
		var kick_offset: Vector2i = previous_kick[x] - current_kick[x]
		var candidate: Tetromino = Tetromino.new(piece.type, piece.position + kick_offset, piece.rotation)
		if not _piece_is_colliding(candidate, board):
			return candidate
	return null


func _create_new_piece(type: int):
	var piece: Tetromino = Tetromino.new(type, Vector2i.ZERO, 0)
	var dimensions = _piece_size(piece)
	piece.position.x = HALF_BOARD_SIZE.x - dimensions.min.x - ceil(dimensions.size.x / 2.0)
	piece.position.y = -dimensions.max.y
	not_held = true
	return piece


func _get_cleared_lines(board: Array) -> PackedInt64Array:
	var cleared_lines: PackedInt64Array = []
	for y in range(board.size()):
		if not board[y].has(0):
			cleared_lines.append(y)
	return cleared_lines


func _clear_lines(board: Array) -> Array:
	var new_board: Array = board.duplicate(true)
	for y in range(new_board.size()):
#		var y = new_board.size() - oy - 1
		if not new_board[y].has(0):
			new_board.remove_at(y)
			new_board.insert(0, [])
			for x in range(board[0].size()):
				new_board[0].append(0)
	
	return new_board.duplicate(true)


func _lock_piece():
	current_piece_array = _create_board_from_piece(current_piece, HALF_BOARD_SIZE)
	gameboard_array = _combine_boards(gameboard_array, current_piece_array)
	var cleared_lines = _get_cleared_lines(gameboard_array)
	if cleared_lines.size() > 0:
		for x in cleared_lines:
			var pos = Vector2(0, -HALF_BOARD_SIZE.y * GAMEBOARD.tile_set.tile_size.y + x * GAMEBOARD.tile_set.tile_size.y)
			var scene = LINE_CLEAR_EFFECT.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			scene.position = pos
			add_child(scene)
		lines_cleared += cleared_lines.size()
	gameboard_array = _clear_lines(gameboard_array)
	current_piece = null
	if bag.size() < TETROMINOES.size():
		bag.append_array(_generate_bag(TETROMINOES.size()))
	
	pieces_placed += 1
	fall_speed = _get_speed(floor(float(lines_cleared) / 10))
	$Background.material.set_shader_parameter("modulate", 1.0 - 1.0 / (0.2 * lines_cleared + 1.0))


func _swap(a: int, b: int, array: Array):
	var temp = array[a]
	array[a] = array[b]
	array[b] = temp


func _generate_bag(max: int) -> Array:
	var array: Array = range(max)
	for i in range(array.size()):
		_swap(i, randi_range(i, array.size() - 1), array)
	return array


func _draw_piece(type: int, old_type: int, pos: Vector2i, tilemap: TileMap):
	var piece_array: Array = TETROMINOES[type]
	var dimensions: Dictionary = _piece_size(Tetromino.new(type, Vector2i.ZERO, 0))
	var offset: Vector2i = pos - dimensions.min
	var positions: Array = []
	if not old_type == -1:
		var old_offset: Vector2i = pos - dimensions.min
		var old_dimensions: Dictionary = _piece_size(Tetromino.new(old_type, Vector2i.ZERO, 0))
		for y in range(piece_array.size()):
			for x in range(piece_array[y].size()):
					tilemap.set_cell(old_type + 1, Vector2i(x, y) + old_offset)
	for y in range(piece_array.size()):
		for x in range(piece_array[y].size()):
			if piece_array[y][x] > 0:
				positions.append(Vector2i(x, y) + offset)
	tilemap.set_cells_terrain_connect(type + 1, positions, 0, 0, true)


func _position_text(node: Label, alignment: Vector2, offset: Vector2):
	if not label_offsets.has(node):
		label_offsets.merge({ node: node.position })
	node.position = label_offsets[node] + Vector2(GAMEBOARD.tile_set.tile_size) * (Vector2(HALF_BOARD_SIZE.x, HALF_BOARD_SIZE.y) + offset) * alignment


func _reset_game():
	_initialize_gameboard_array(gameboard_array, HALF_BOARD_SIZE)
	bag = _generate_bag(TETROMINOES.size())
	bag.append_array(_generate_bag(TETROMINOES.size()))
	hold = -1
	lines_cleared = 0
	old_gameboard = gameboard_array


func _hard_drop(o_piece: Tetromino, array: Array) -> Tetromino:
	var piece = o_piece.duplicate()
	while not _piece_is_colliding(piece, array):
		piece.position.y += 1
	
	piece.position.y -= 1
	return piece


func _new_game_piece():
	current_piece = _create_new_piece(bag[0])
	if _piece_is_colliding(current_piece, gameboard_array, false):
		death.emit()
	bag.remove_at(0)
	fall_time = 0.0


func _get_speed(in_level: float = -1.0) -> float:
	var level = in_level - 1
	if in_level == -1.0:
		level = floor(float(lines_cleared) / 10) - 1
	return (0.8 - level * 0.007) ** level
