@tool
extends Control

signal death

@export var GAMEBOARD: TileMap
@export var HALF_BOARD_SIZE: Vector2i = Vector2i(5, 10)
@export var TILE_TO_ATLAS: Dictionary = { 0: Vector2i(3, 0), 1: Vector2i(4, 0)}
@export var BASE_DROP_SPEED: float = 0.1
@export var FALL_LOCK_MAX: int = 1
@export var FIRST_MOVE_INTERVAL: float = 0.2
@export var MOVE_INTERVAL: float = 0.1
@export var LINE_CLEAR_EFFECT: PackedScene = preload("res://scenes/game_scene/explosion/explosion.tscn")
@export var SHOW_GHOST_BLOCK: bool = true
@export var HARD_DROP_MOVE_AMOUNT: float = -6.0
@export var LINE_CLEAR_MOVE_AMOUNT: float = -12.0

@export var line_clear_test: PackedInt32Array
@export_tool_button("test explosion") var line_clear_test_fn = func():
		for cleared_line in line_clear_test:
			var gameboard_tile_size := Vector2(GAMEBOARD.tile_set.tile_size) * GAMEBOARD.scale
			var pos := Vector2(0, -HALF_BOARD_SIZE.y + cleared_line + 0.5) * gameboard_tile_size.y + GAMEBOARD.position
			var scene: GPUParticles2D = LINE_CLEAR_EFFECT.instantiate()
			scene.position = pos
			#scene.amount = (combo + 1) * scene.amount
			add_child(scene)
			scene.explode()

@onready var main_camera: MainCamera = %MainCamera
@onready var lines_cleared_label: Label = %LinesCleared
@onready var hold_label: Label = %Hold
@onready var next_label: Label = %Next
@onready var alert_label: Label = %Alert

const TETROMINOES: Array[Array] = [
	# I tetromino
	[[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0],
	[0, 1, 1, 1, 1],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
	# J tetromino
	[[0, 0, 0, 0, 0],
	[0, 1, 0, 0, 0],
	[0, 1, 1, 1, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
	# L tetromino
	[[0, 0, 0, 0, 0],
	[0, 0, 0, 1, 0],
	[0, 1, 1, 1, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
	# O tetromino
	[[0, 0, 0, 0, 0],
	[0, 0, 1, 1, 0],
	[0, 0, 1, 1, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
	# S tetromino
	[[0, 0, 0, 0, 0],
	[0, 0, 1, 1, 0],
	[0, 1, 1, 0, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
	# T tetromino
	[[0, 0, 0, 0, 0],
	[0, 0, 1, 0, 0],
	[0, 1, 1, 1, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
	# Z tetromino
	[[0, 0, 0, 0, 0],
	[0, 1, 1, 0, 0],
	[0, 0, 1, 1, 0],
	[0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0]],
]

const JLSTZ_KICK_OFFSETS: Array[Array] = [
	[Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0)],
	[Vector2i( 0, 0), Vector2i( 1, 0), Vector2i( 1,-1), Vector2i( 0, 2), Vector2i( 1, 2)],
	[Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0)],
	[Vector2i( 0, 0), Vector2i(-1, 0), Vector2i(-1,-1), Vector2i( 0, 2), Vector2i(-1, 2)],
]

const I_KICK_OFFSETS: Array[Array] = [
	[Vector2i( 0, 0), Vector2i(-1, 0), Vector2i( 2, 0), Vector2i(-1, 0), Vector2i( 2, 0)],
	[Vector2i(-1, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 1), Vector2i( 0,-2)],
	[Vector2i(-1, 1), Vector2i( 1, 1), Vector2i(-2, 1), Vector2i( 1, 0), Vector2i(-2, 0)],
	[Vector2i( 0, 1), Vector2i( 0, 1), Vector2i( 0, 1), Vector2i( 0,-1), Vector2i( 0, 2)],
]

const O_KICK_OFFSETS: Array[Array] = [
	[Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0), Vector2i( 0, 0)],
	[Vector2i( 0,-1), Vector2i( 0,-1), Vector2i( 0,-1), Vector2i( 0,-1), Vector2i( 0,-1)],
	[Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-1,-1), Vector2i(-1,-1)],
	[Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0), Vector2i(-1, 0)],
]

const KICK_OFFSETS: Array = [
	I_KICK_OFFSETS,
	JLSTZ_KICK_OFFSETS,
	JLSTZ_KICK_OFFSETS,
	O_KICK_OFFSETS,
	JLSTZ_KICK_OFFSETS,
	JLSTZ_KICK_OFFSETS,
	JLSTZ_KICK_OFFSETS,
]

const TETROMINO_SIZE: PackedInt32Array = [
	4,
	3,
	3,
	2,
	4,
	3,
	4,
]

var old_hash: int
var old_gameboard: Array
var old_ghost: Array
var old_bag_piece: int
var old_hold: int

var gameboard_array: Array = []
var gameboard_size: Vector2i

var lines_cleared: int
var pieces_placed: int
var combo: int

var bag: Array
var hold: int
var not_held: bool

var fall_time: float
var fall_speed: float
var fall_lock: int

var current_piece: Tetromino
var current_piece_array: Array

var move_time: float
var move_chain: int

var label_offsets: Dictionary = {}

func _ready() -> void:
	if not Engine.is_editor_hint():
		fall_speed = _get_speed()
		gameboard_size = HALF_BOARD_SIZE * 2
		
		_reset_game()
		GAMEBOARD.clear()
		_construct_gameboard_borders(GAMEBOARD, 10, HALF_BOARD_SIZE)
	
	var board_size := Vector2(GAMEBOARD.tile_set.tile_size * HALF_BOARD_SIZE) * GAMEBOARD.scale * 2.0
	for label: Label in [next_label, hold_label, lines_cleared_label]:
		label.size.x = board_size.x
		label.position = Vector2(-1, 1) * Vector2(GAMEBOARD.tile_set.tile_size) * (Vector2(HALF_BOARD_SIZE) + Vector2(0, 0)) * GAMEBOARD.scale + GAMEBOARD.position

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		_process_current_piece(delta)
		var array = gameboard_array
		if not current_piece == null:
			array = _combine_boards(array, current_piece_array)
		if not (str(array) + str(hold)).hash() == old_hash:
			_draw_gameboard_to_tileset(array, GAMEBOARD, HALF_BOARD_SIZE, SHOW_GHOST_BLOCK, current_piece, gameboard_array)
			_draw_piece(bag[0], old_bag_piece, Vector2i(-HALF_BOARD_SIZE.x, HALF_BOARD_SIZE.y + 2), GAMEBOARD, HORIZONTAL_ALIGNMENT_LEFT)
			
			if hold != -1:
				_draw_piece(hold, old_hold, Vector2i(HALF_BOARD_SIZE.x, HALF_BOARD_SIZE.y + 2), GAMEBOARD, HORIZONTAL_ALIGNMENT_RIGHT)
			
			old_hash = (str(array) + str(hold)).hash()
			old_bag_piece = bag[0]
			old_hold = hold
			lines_cleared_label.text = "lines\n%s" % lines_cleared
	else:
		var board_size := Vector2(GAMEBOARD.tile_set.tile_size * HALF_BOARD_SIZE) * GAMEBOARD.scale * 2.0
		for label: Label in [next_label, hold_label, lines_cleared_label]:
			label.size.x = board_size.x
			label.position = Vector2(-1, 1) * Vector2(GAMEBOARD.tile_set.tile_size) * (Vector2(HALF_BOARD_SIZE) + Vector2(0, 0)) * GAMEBOARD.scale + GAMEBOARD.position


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
			
			var move_axis := Input.get_axis("move_left", "move_right")
			
			if move_axis and (move_time > (FIRST_MOVE_INTERVAL if move_chain <= 1 else MOVE_INTERVAL) or move_time < 0.0):
				current_piece.position.x += move_axis
				if _piece_is_colliding(current_piece, gameboard_array, true):
					current_piece.position.x -= move_axis
				move_time = 0.0
				move_chain += 1
			elif not move_axis:
				move_time = -1.0
				move_chain = 0
			
			if Input.is_action_just_pressed("hard_drop"):
				current_piece = _hard_drop(current_piece, gameboard_array)
				var cleared_lines := _lock_piece()
				main_camera.move(Vector2(0, HARD_DROP_MOVE_AMOUNT + LINE_CLEAR_MOVE_AMOUNT * cleared_lines.size()))
			
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


func _initialize_gameboard_array(array: Array, half_size: Vector2i, data: Callable = func(_x: Vector2i):
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


func _draw_gameboard_to_tileset(e_array: Array, tilemap: TileMap, half_size: Vector2i, draw_ghost: bool, ghost_piece: Tetromino, array_no_piece: Array):
	var array: Array  = e_array.duplicate(true)
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
				delete[old_board_value].append(Vector2i(x, y) - half_size)
			if _2d_index(array, Vector2i(x, y)) == 0:
				tilemap.set_cell(9, Vector2i(x, y) - half_size, 0, Vector2i(3, 0))
			else:
				tilemap.set_cell(9, Vector2i(x, y) - half_size)
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
	var array: Array = []
	_initialize_gameboard_array(array, half_size)
	
	var piece_array: Array = _rotate_piece(TETROMINOES[piece.type], piece.rotation)
	
	for y in range(piece_array.size()):
		for x in range(piece_array[y].size()):
			var full_position: Vector2i = piece.position + Vector2i(x, y)
			if full_position.x >= 0 and full_position.x < array[y].size():
				if full_position.y >= 0 and full_position.y < array.size():
					array[full_position.y][full_position.x] = data + 1 if piece_array[y][x] > 0 else 0
	
	return array


var piece_sizes: Dictionary[Tetromino, Dictionary]


func _piece_size(piece: Tetromino) -> Dictionary[StringName, Vector2i]:
	#if piece in piece_sizes:
		#return piece_sizes[piece]
	var array: Array = _rotate_piece(TETROMINOES[piece.type], piece.rotation)
	var min_pos: Vector2i = Vector2i(array[0].size(), array.size())
	var max_pos: Vector2i = Vector2i.ZERO
	for y in range(array.size()):
		for x in range(array[y].size()):
			var pos: Vector2i = Vector2i(x, y)
			var data: int = _2d_index(array, pos)
			if data > 0:
				min_pos.x = mini(min_pos.x, pos.x)
				min_pos.y = mini(min_pos.y, pos.y)
				max_pos.x = maxi(max_pos.x, pos.x)
				max_pos.y = maxi(max_pos.y, pos.y)
	var piece_info: Dictionary[StringName, Vector2i] = { "min": min_pos, "max": max_pos, "size": max_pos - min_pos + Vector2i.ONE }
	#piece_sizes[piece] = piece_info
	return piece_info


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
	var res: Array = []
	for y in range(array_0.size()):
		res.append([])
		for x in range(array_0[y].size()):
			var pos = Vector2i(x, y)
			var data_0 = _2d_index(array_0, pos)
			var data_1 = _2d_index(array_1, pos)
			res[y].append(data_0 if data_0 > 0 else data_1)
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
	var dimensions := _piece_size(piece)
	piece.position.x = HALF_BOARD_SIZE.x - dimensions.min.x - ceil(dimensions.size.x / 2.0)
	piece.position.y = -dimensions.max.y
	not_held = true
	return piece


func _get_cleared_lines(board: Array) -> PackedInt32Array:
	var cleared_lines: PackedInt32Array = []
	for y in range(board.size()):
		if not board[y].has(0):
			cleared_lines.append(y)
	return cleared_lines


func _clear_lines(board: Array) -> Array:
	var new_board: Array = board.duplicate(true)
	for y in range(new_board.size()):
		#var y = new_board.size() - oy - 1
		if not new_board[y].has(0):
			new_board.remove_at(y)
			new_board.insert(0, [])
			for x in range(board[0].size()):
				new_board[0].append(0)
	
	return new_board.duplicate(true)


func _lock_piece() -> PackedInt32Array:
	current_piece_array = _create_board_from_piece(current_piece, HALF_BOARD_SIZE)
	gameboard_array = _combine_boards(gameboard_array, current_piece_array)
	var cleared_lines := _get_cleared_lines(gameboard_array)
	if cleared_lines.size() > 0:
		for cleared_line in cleared_lines:
			var gameboard_tile_size := Vector2(GAMEBOARD.tile_set.tile_size) * GAMEBOARD.scale
			var pos := Vector2(0, -HALF_BOARD_SIZE.y + cleared_line + 0.5) * gameboard_tile_size.y + GAMEBOARD.position
			var scene: GPUParticles2D = LINE_CLEAR_EFFECT.instantiate()
			scene.position = pos
			#scene.amount = (combo + 1) * scene.amount
			add_child(scene)
			scene.explode()
		lines_cleared += cleared_lines.size()
		combo += 1
		if combo > 1:
			var combo_text := alert_label.duplicate() as Label
			combo_text.text += str(combo)
			var color: Color = GAMEBOARD.get_layer_modulate(current_piece.type + 1)
			combo_text.modulate = Color(color, combo_text.modulate.a).lightened(0.5)
			add_child(combo_text)
			combo_text.animate()
		var vibration_strength := 1.0 - exp(-cleared_lines.size() * 0.35 - combo + 1)
		Input.vibrate_handheld(300, vibration_strength)
	else:
		combo = 0

	gameboard_array = _clear_lines(gameboard_array)
	current_piece = null
	if bag.size() < TETROMINOES.size():
		bag.append_array(_generate_bag(TETROMINOES.size()))
	
	pieces_placed += 1
	fall_speed = _get_speed(floor(float(lines_cleared) / 10))
	
	return cleared_lines


func _swap(a: int, b: int, array: Array):
	var temp = array[a]
	array[a] = array[b]
	array[b] = temp


func _generate_bag(max_value: int) -> Array:
	var array: Array = range(max_value)
	for i in range(array.size()):
		_swap(i, randi_range(i, array.size() - 1), array)
	return array


func _draw_piece(type: int, old_type: int, pos: Vector2i, tilemap: TileMap, alignment: HorizontalAlignment):
	var piece_array := TETROMINOES[type]
	var dimensions := _piece_size(Tetromino.new(type, Vector2i.ZERO, 0))
	var offset: Vector2i = pos - dimensions.min
	if alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		offset.x -= dimensions.size.x
	var positions: Array = []
	if not old_type == -1:
		var old_dimensions := _piece_size(Tetromino.new(old_type, Vector2i.ZERO, 0))
		var old_offset: Vector2i = pos - old_dimensions.min
		if alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			old_offset.x -= old_dimensions.size.x
		var old_piece_array: Array = TETROMINOES[old_type]
		for y in old_piece_array.size():
			for x in old_piece_array[y].size():
					tilemap.set_cell(old_type + 1, Vector2i(x, y) + old_offset)
	for y in piece_array.size():
		for x in piece_array[y].size():
			if piece_array[y][x] > 0:
				positions.append(Vector2i(x, y) + offset)
	tilemap.set_cells_terrain_connect(type + 1, positions, 0, 0, true)


func _position_text(node: Label, alignment: Vector2, offset: Vector2):
	#if node not in label_offsets:
		#label_offsets[node] = node.position
	node.position = Vector2(0.0, -node.size.y * 0.5) + (
		+ GAMEBOARD.scale
			* Vector2(GAMEBOARD.tile_set.tile_size)
			* (Vector2(HALF_BOARD_SIZE) + offset)
			* alignment
		+ GAMEBOARD.position
	)


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
	var level := in_level - 1
	if in_level == -1.0:
		level = floorf(lines_cleared / 10.0) - 1
	return (0.8 - level * 0.007) ** level
