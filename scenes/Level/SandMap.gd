extends TileMap

@export_category("Noise")
@export var zone: Rect2i = Rect2i(-32, -32, 64, 64)
@export var sand_cap: float = 0.1
@export var noise_scale: float = 10.0

func _ready():
	_generate_sand()


func _generate_sand():
	var noise = FastNoiseLite.new()
	noise.seed = randi()

	var cells = []

	for x in range(zone.position.x, zone.position.x + zone.size.x):
		for y in range(zone.position.y, zone.position.x + zone.size.y):
			var ns = noise.get_noise_2d(x * noise_scale, y * noise_scale)
			if ns < sand_cap:
				cells.append(Vector2i(x, y))
			#else:
				#set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0), 0)

	set_cells_terrain_connect(0, cells, 0, 0)
