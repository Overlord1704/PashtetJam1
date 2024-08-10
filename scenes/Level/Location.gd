extends Node2D


var _grid = []
var _visited = []
var _pipes = []
var _broken = []
var _broken_codes = []

var DIRS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
var S_DIRS = 'lrud'

var TILE = 32


@onready var label = $Elements/Label
@onready var pipes = $Pipes

@onready var pipes_dict = {
	'l': $Elements/PipeL, 'r': $Elements/PipeR, 'u': $Elements/PipeU, 'd': $Elements/PipeD,
	'lr': $Elements/PipeLR, 'ud': $Elements/PipeUD,
	'ld': $Elements/PipeLD, 'lu': $Elements/PipeLU, 'ru': $Elements/PipeRU, 'rd': $Elements/PipeRD,
	'lrd': $Elements/PipeLRD, 'rud': $Elements/PipeRUD, 'lud': $Elements/PipeLUD, 'lru': $Elements/PipeLRU,
	'lrud': $Elements/PipeLRUD
}


func get_broken():
	return _broken


func _ready():

	generate_grid(12, 12)
	generate_pipes()

	build()


func generate_grid(width, height):
	# создание решетки
	_grid = []
	for i in range(height):
		var row = []
		for j in range(width):
			row.append(true)
		_grid.append(row)

	var holes = []

	var N = 5
	while holes.size() < N:
		var w = randi_range(width / 4, width / 2)
		var h = randi_range(height / 4, height / 2)

		var x = randi_range(-w, width - 1)
		var y = randi_range(-h, height - 1)

		var new_hole = Rect2i(x, y, w, h)

		var found = false
		for hole: Rect2i in holes:
			if hole.intersects(new_hole.grow(2)):
				found = true

		if not found:
			holes.append(new_hole)

		#_grid[y][x] = false

	print(holes)

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

	var broken_scenes = []

	for i in range(n):
		for j in range(m):
			var pos = Vector2(j * TILE, i * TILE) + Vector2(TILE / 2, TILE / 2)

			#var new_element: Label = label.duplicate()
			#new_element.text = _pipes[i][j]
			var code = _pipes[i][j]

			if len(code) == 0:
				continue

			var new_element: Sprite2D = pipes_dict[code].duplicate()

			new_element.scale = Vector2(2, 2)

			if Vector2i(j, i) not in _broken:
				new_element.global_position = pos
				pipes.add_child(new_element)
			else:
				var w = TILE * (m + 0.5)
				var h = TILE * (n + 0.5)
				var random_pos = Vector2(randf() * w * 0.5, randf() * h)
				new_element.global_position = Vector2(w, 0) + random_pos
				new_element.rotation = randf() * PI * 2.0
				add_child(new_element)

			new_element.show()




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
	var broken = []
	while broken.size() < num_broken:
		var num = randi_range(0, results.size() - 1)
		if num in broken:
			continue
		broken.append(num)

	_broken = []
	_broken_codes = []
	for num in broken:
		_broken.append(results[num][0])
		_broken_codes.append(neighbors[num])
