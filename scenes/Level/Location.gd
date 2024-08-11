extends Node2D

@export_category("Generation")
@export var width: int = 12
@export var height: int = 12
@export var num_holes: int = 4 # Кол-во дырок
@export var hole_min: int = 2
@export var hole_max: int = 4
@export var random_add: int = 32
@export var random_sub: int = 8

var _grid = []
var _visited = []
var _pipes = []
var _broken = []
var _broken_codes = []
var _sprites = []
var _sprites_broken = []

var DIRS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
var S_DIRS = 'lrud'

var TILE = 32

var PipeScene = preload("res://scenes/Level/pipe.tscn")
var PlaceScene = preload("res://scenes/Level/place.tscn")

@onready var label = $Elements/Label
@onready var pipes = $Pipes

@onready var pipes_dict = {
	'l': $Elements/PipeL, 'r': $Elements/PipeR, 'u': $Elements/PipeU, 'd': $Elements/PipeD,
	'lr': $Elements/PipeLR, 'ud': $Elements/PipeUD,
	'ld': $Elements/PipeLD, 'lu': $Elements/PipeLU, 'ru': $Elements/PipeRU, 'rd': $Elements/PipeRD,
	'lrd': $Elements/PipeLRD, 'rud': $Elements/PipeRUD, 'lud': $Elements/PipeLUD, 'lru': $Elements/PipeLRU,
	'lrud': $Elements/PipeLRUD
}

# 5 types: I, J, T, X, O
const TYPES = {
	'': '',
	'l': 'O', 'r': 'O', 'u': 'O', 'd': 'O',
	'lr': 'I', 'ud': 'I',
	'ld': 'J', 'lu': 'J', 'ru': 'J', 'rd': 'J',
	'lrd': 'T', 'rud': 'T', 'lud': 'T', 'lru': 'T',
	'lrud': 'X'
}

func get_broken():
	return _broken


func _ready():

	generate_grid()
	generate_pipes()

	build()


func generate_grid():
	# создание решетки
	_grid = []
	for i in range(height):
		var row = []
		for j in range(width):
			if i % 3 == 0 or j % 3 == 0:
				row.append(true)
			else:
				row.append(false)
		_grid.append(row)

	# произвольное добавление ячеек
	for i in range(random_add):
		var ri = randi_range(0, height - 1)
		var rj = randi_range(0, width - 1)
		_grid[ri][rj] = true

	# произвольное убирание ячеек
	for i in range(random_sub):
		var ri = randi_range(0, height - 1)
		var rj = randi_range(0, width - 1)
		_grid[ri][rj] = false

	# вырезание пустот на карте
	var holes = []

	var iter = 0
	var max_iter = 100

	var N = num_holes
	while holes.size() < N and iter < max_iter:
		var w = randi_range(hole_min, hole_max)
		var h = randi_range(hole_min, hole_max)

		var x = randi_range(-w, width - 1)
		var y = randi_range(-h, height - 1)

		var new_hole = Rect2i(x, y, w, h)

		var found = false
		for hole: Rect2i in holes:
			if hole.intersects(new_hole.grow(1)):
				found = true

		if not found:
			holes.append(new_hole)

		iter += 1
		#_grid[y][x] = false

	print(holes.size())

	var counter = 0
	for hole: Rect2i in holes:
		var x1 = max(0, hole.position.x)
		var y1 = max(0, hole.position.y)

		var x2 = min(width, hole.position.x + hole.size.x)
		var y2 = min(height, hole.position.y + hole.size.y)

		for i in range(y1, y2):
			for j in range(x1, x2):
				_grid[i][j] = false
				counter += 1

	print("Total:", counter, ' ', width * height)


func valid_cell(pos: Vector2i):
	var n = _grid.size()
	var m = _grid[0].size()

	if pos.x < 0 or pos.x >= m or pos.y < 0 or pos.y >= n:
		return false

	if not _grid[pos.y][pos.x]:
		return false

	if _visited[pos.y][pos.x]:
		return false

	return true


func build():
	var n = _grid.size()
	var m = _grid[0].size()

	# таблица спрайтов
	_sprites = []
	for i in range(n):
		var row = []
		for j in range(m):
			row.append(null)
		_sprites.append(row)

	var broken_scenes = []

	_sprites_broken = []

	for i in range(n):
		for j in range(m):
			var pos = Vector2(j * TILE, i * TILE) + Vector2(TILE / 2, TILE / 2)

			#var new_element: Label = label.duplicate()
			#new_element.text = _pipes[i][j]
			var code = _pipes[i][j]
			var type = TYPES[code]

			if len(code) == 0:
				continue

			var new_element: Sprite2D = pipes_dict[code].duplicate()

			new_element.scale = Vector2(2, 2)

			if Vector2i(j, i) in _broken:
				# сцена плейса трубы
				var place_scene: _PlaceObject = PlaceScene.instantiate()
				place_scene.set_sprite(new_element)
				add_child(place_scene)
				place_scene.position = pos
				place_scene.type = type
				place_scene.code = code

				_sprites[i][j] = place_scene.get_sprite()
				_sprites_broken.append(place_scene.get_sprite())
				#print('Sprites Broken: ', _sprites_broken.size())

				# сцена элемента трубы
				var pipe_element = new_element.duplicate()
				pipe_element.position = Vector2.ZERO
				var pipe_scene: _TakeObject = PipeScene.instantiate()
				pipe_scene.add_child(pipe_element)
				add_child(pipe_scene)
				pipe_element.show()
				pipe_scene.type = type
				pipe_scene.code = code

				var w = TILE * (m + 0.5)
				var h = TILE * (n + 0.5)

				#var random_pos = Vector2(randf() * w * 0.5, randf() * h)
				#pipe_scene.position = Vector2(w, 0) + random_pos
				var random_pos = spawn_pipe(w, h)
				pipe_scene.position = random_pos
				# print(random_pos)

				pipe_scene.rotation = randf() * PI * 2.0
			else:
				new_element.position = pos
				pipes.add_child(new_element)
				new_element.show()

				_sprites[i][j] = new_element


func spawn_pipe(width, height):
	# random position вне квадрата с трубами
	var offset = Vector2(-width * 0.5, -height * 0.5)
	var rp = Vector2(randf() * width * 2, randf() * height * 2) + offset
	while rp.x >= 0 and rp.x <= width and rp.y >= 0 and rp.y <= height:
		rp = Vector2(randf() * width * 2, randf() * height * 2) + offset
	return rp


func generate_pipes(num_broken: int = 8):
	#
	# создание лабиринта из труб
	#

	var n = _grid.size()
	var m = _grid[0].size()

	# инициализация алгоритма
	_visited = []
	for i in range(n):
		var row = []
		for j in range(m):
			row.append(false)
		_visited.append(row)


	# начальная клетка
	var pos0 = Vector2i(randi_range(0, m - 1), randi_range(0, n - 1))
	while not valid_cell(pos0):
		pos0 = Vector2i(randi_range(0, m - 1), randi_range(0, n - 1))


	var stack = []
	stack.append([pos0, -1])

	var results = []

	# поиск в глубину
	while stack.size() > 0:

		var current = stack.pop_back()
		var pos = current[0]
		var parent = current[1]

		if not valid_cell(pos):
			continue

		_visited[pos.y][pos.x] = true

		results.append([pos, parent])

		var new_parent = results.size() - 1
		var new_stack: Array = []

		# добавление соседей в стек
		for k in range(4):
			var new_pos = pos + DIRS[k]
			new_stack.append([new_pos, new_parent])

		new_stack.shuffle()
		stack.append_array(new_stack)

	# восстанавливаем соседей для каждой клетки
	var neighbors = []
	for k in range(results.size()):
		neighbors.append([false, false, false, false])

	for k in range(results.size()):
		var result = results[k]

		var pos = result[0]
		var parent = result[1]

		if parent < 0:
			continue

		var neighbor = results[parent]
		var n_pos = neighbor[0]

		var delta_pos = n_pos - pos

		var index
		var parent_index

		# выставляем флажки у соседей
		if delta_pos.y == 0:
			if delta_pos.x == -1:
				index = 0
				parent_index = 1
			else:
				index = 1
				parent_index = 0
		else:
			if delta_pos.y == -1:
				index = 2
				parent_index = 3
			else:
				index = 3
				parent_index = 2

		neighbors[k][index] = true
		neighbors[parent][parent_index] = true


	# заполняем сетку кодами соседей
	_pipes = []
	for i in range(n):
		var row = []
		for j in range(m):
			row.append('')
		_pipes.append(row)

	for k in range(results.size()):
		var pos = results[k][0]
		var code = neighbors[k]

		var s_code = ''
		for l in range(4):
			if code[l]:
				s_code += S_DIRS[l]

		_pipes[pos.y][pos.x] = s_code

	# взять num_broken случайных элементов
	var iter_broken = 0
	var max_iter_broken = 100

	var broken = []
	while broken.size() < num_broken and iter_broken < max_iter_broken:
		iter_broken += 1
		var num = randi_range(0, results.size() - 1)
		if num in broken:
			continue
		broken.append(num)

	print("Broken: ", broken.size())

	_broken = []
	_broken_codes = []
	for num in broken:
		_broken.append(results[num][0])
		_broken_codes.append(neighbors[num])


func _process(delta):
	var n = _grid.size()
	var m = _grid[0].size()

	#print(_sprites_broken.size())

	for _broken_sprite in _sprites_broken:
		#print(_broken_sprite)
		if not _broken_sprite.visible:
			continue

		var pos0 = _broken_sprite.global_position
		for i in range(n):
			for j in range(m):
				var sprite: Sprite2D = _sprites[i][j]

				if sprite and pos0.distance_to(sprite.global_position) < 32 * 8:
					sprite.self_modulate = Color.BLUE

