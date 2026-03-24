extends Node2D

@export var level_path : String
@export var tile_size : int = 64
const DEFAULT_LEVEL := "res://levels/level_01.txt"

var grid := []
var player : CharacterBody2D
var file_dialog : FileDialog
var canvas_layer : CanvasLayer

func _ready() -> void:
	set_process(true)
	set_physics_process(true)

	if level_path == "" or level_path == null:
		level_path = DEFAULT_LEVEL

	print("2D isometric: cargando nivel ", level_path)

	if not load_level(level_path):
		push_error("No se pudo cargar el nivel: %s" % level_path)
		return

	print("2D isometric: grid", grid)
	build_level()

	# FileDialog para cambiar nivel con tecla L
	file_dialog = FileDialog.new()
	file_dialog.filters = ["*.txt"]
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)

	# Botón para volver al menú (en CanvasLayer para que sea fijo en pantalla)
	self.canvas_layer = CanvasLayer.new()
	var back_button = Button.new()
	back_button.text = "Volver al Menú"
	back_button.position = Vector2(10, 10)
	back_button.connect("pressed", Callable(self, "_on_back_to_menu"))
	self.canvas_layer.add_child(back_button)
	add_child(self.canvas_layer)

func _process(delta: float) -> void:
	if player == null:
		return

	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	if velocity != Vector2.ZERO:
		velocity = velocity.normalized() * 150
	player.velocity = velocity
	player.move_and_slide()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_L and event.pressed:
		file_dialog.popup()

func _on_file_selected(path: String) -> void:
	clear_level()
	level_path = path
	if load_level(path):
		build_level()

func clear_level() -> void:
	for child in get_children():
		if child != file_dialog and child != canvas_layer:
			child.queue_free()
	player = null

func load_level(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("No existe: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir: " + path)
		return false

	grid.clear()
	while not file.eof_reached():
		grid.append(file.get_line())
	file.close()
	return true

func build_level() -> void:
	for y in range(grid.size()):
		var line = grid[y]
		for x in range(line.length()):
			var symbol = line[x]
			var world_pos = iso_from_cartesian(Vector2(x, y))
			match symbol:
				"#":
					spawn_iso_tile(world_pos, Color(0.2, 0.2, 0.2))
					spawn_iso_wall(world_pos)
				".":
					spawn_iso_tile(world_pos, Color(0.5, 0.5, 0.5))
				"P":
					spawn_iso_tile(world_pos, Color(0.5, 0.5, 0.5))
					spawn_player(world_pos)

func iso_from_cartesian(cart: Vector2) -> Vector2:
	var half = tile_size * 0.5
	var x = (cart.x - cart.y) * half
	var y = (cart.x + cart.y) * (half * 0.5)
	return Vector2(x, y)

func spawn_iso_tile(pos: Vector2, color: Color) -> void:
	var poly = Polygon2D.new()
	var r = tile_size * 0.5
	poly.polygon = [Vector2(0, -r*0.5), Vector2(r, 0), Vector2(0, r*0.5), Vector2(-r,0)]
	poly.position = pos
	poly.color = color
	add_child(poly)

func spawn_iso_wall(pos: Vector2) -> void:
	var body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size * 0.7, tile_size * 0.7)
	collision.shape = shape
	body.position = pos - Vector2(0, tile_size * 0.25)
	body.add_child(collision)
	add_child(body)

func spawn_player(pos: Vector2) -> void:
	player = CharacterBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size * 0.5, tile_size * 0.5)
	collision.shape = shape
	player.add_child(collision)

	var rect = ColorRect.new()
	rect.color = Color(0, 1, 0)
	rect.size = Vector2(tile_size * 0.5, tile_size * 0.5)
	rect.position = -rect.size * 0.5
	player.add_child(rect)

	player.position = pos - Vector2(0, tile_size * 0.15)
	player.z_index = 10

	var camera = Camera2D.new()
	camera.enabled = true
	camera.make_current()
	camera.zoom = Vector2(0.75, 0.75)
	player.add_child(camera)

	add_child(player)

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/001-menu/menu.tscn")
