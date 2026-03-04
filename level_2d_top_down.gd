extends Node2D

@export var level_path : String
@export var tile_size : int = 32

var grid := []
var player := ColorRect.new()  # variable global para guardar el jugador

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
	player.color = Color.GREEN
	player.size = Vector2(tile_size, tile_size)
	player.position = pos
	player.z_index = 10 
	add_child(player)
	
func _process(delta):
	if player == null:
		return  # todavía no se ha creado el jugador

	var move = Vector2.ZERO

	# Movimiento simple con flechas
	if Input.is_action_pressed("ui_up"):
		move.y -= 1
	if Input.is_action_pressed("ui_down"):
		move.y += 1
	if Input.is_action_pressed("ui_left"):
		move.x -= 1
	if Input.is_action_pressed("ui_right"):
		move.x += 1

	if move != Vector2.ZERO:
		move = move.normalized() #* tile_size  # mover por tamaño de tile
		player.position += move
