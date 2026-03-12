extends Node2D

@export var level_path : String
@export var tile_size : int = 32

var grid := []
var player : CharacterBody2D  # cambiar a CharacterBody2D
var file_dialog : FileDialog

func _ready():
	if level_path == "":
		push_error("No hay level_path definido")
		return

	load_level(level_path)
	build_level()

	# Crear el FileDialog
	file_dialog = FileDialog.new()
	file_dialog.filters = ["*.txt"]
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_L and event.pressed:
		file_dialog.popup()

func _on_file_selected(path):
	clear_level()
	load_level(path)
	build_level()

func clear_level():
	for child in get_children():
		if child != file_dialog:
			child.queue_free()
	player = null  # resetear el player

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
	var body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size, tile_size)
	collision.shape = shape
	body.position = pos + Vector2(tile_size/2, tile_size/2)  # centro del tile
	body.add_child(collision)
	
	var rect = ColorRect.new()
	rect.color = Color.DARK_GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = -Vector2(tile_size/2, tile_size/2)  # ajustar posición relativa
	body.add_child(rect)
	
	add_child(body)

func spawn_floor(pos):
	var rect = ColorRect.new()
	rect.color = Color.GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = pos
	add_child(rect)

func spawn_player(pos):
	player = CharacterBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size, tile_size)
	collision.shape = shape
	player.add_child(collision)
	
	var rect = ColorRect.new()
	rect.color = Color.GREEN
	rect.size = Vector2(tile_size, tile_size)
	rect.position = -Vector2(tile_size/2, tile_size/2)
	player.add_child(rect)
	
	player.position = pos + Vector2(tile_size/2, tile_size/2)
	player.z_index = 10 
	add_child(player)
	
func _process(delta):
	if player == null:
		return  # todavía no se ha creado el jugador

	var velocity = Vector2.ZERO

	# Movimiento simple con flechas
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	if velocity != Vector2.ZERO:
		velocity = velocity.normalized() * 100  # velocidad arbitraria, ajusta según necesites

	player.velocity = velocity
	player.move_and_slide()
