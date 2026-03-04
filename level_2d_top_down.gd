extends Node2D

@export var level_path : String
@export var tile_size : int = 32

var grid := []

func _ready():
	if level_path == "":
		push_error("No hay level_path definido")
		return

	load_level(level_path)
	build_level()

func load_level(path):
	if not FileAccess.file_exists(path):
		push_error("No existe: " + path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	grid.clear()

	while not file.eof_reached():
		grid.append(file.get_line())

	file.close()

func build_level():
	for y in range(grid.size()):
		var line = grid[y]

		for x in range(line.length()):
			var symbol = line[x]
			var world_pos = Vector2(x, y) * tile_size

			match symbol:
				"#":
					spawn_wall(world_pos)
				".":
					spawn_floor(world_pos)
				"P":
					spawn_floor(world_pos)
					spawn_player(world_pos)
					
func spawn_wall(pos):
	var rect = ColorRect.new()
	rect.color = Color.DARK_GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = pos
	add_child(rect)

func spawn_floor(pos):
	var rect = ColorRect.new()
	rect.color = Color.GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = pos
	add_child(rect)

func spawn_player(pos):
	var rect = ColorRect.new()
	rect.color = Color.GREEN
	rect.size = Vector2(tile_size, tile_size)
	rect.position = pos
	add_child(rect)
