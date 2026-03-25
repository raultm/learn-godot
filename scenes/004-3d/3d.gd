extends Node3D

@export var level_path : String
@export var tile_size : int = 2
const DEFAULT_LEVEL := "res://levels/level_01.txt"

var grid := []
var player : CharacterBody3D
var file_dialog : FileDialog
var canvas_layer : CanvasLayer
var camera_rotation = Vector2(0, 0)
var mouse_sensitivity = 0.1
var pivot : Node3D

func _ready() -> void:
	set_process(true)
	set_physics_process(true)

	if level_path == "" or level_path == null:
		level_path = DEFAULT_LEVEL

	print("3D: cargando nivel ", level_path)

	if not load_level(level_path):
		push_error("No se pudo cargar el nivel: %s" % level_path)
		return

	print("3D: grid", grid)
	build_level()

	# FileDialog para cambiar nivel con tecla L
	file_dialog = FileDialog.new()
	file_dialog.filters = ["*.txt"]
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)

	# Botón para volver al menú (en CanvasLayer para 3D)
	self.canvas_layer = CanvasLayer.new()
	var back_button = Button.new()
	back_button.text = "Volver al Menú"
	back_button.position = Vector2(10, 10)
	back_button.connect("pressed", Callable(self, "_on_back_to_menu"))
	self.canvas_layer.add_child(back_button)
	add_child(self.canvas_layer)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if player == null:
		return

	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		input_dir.y += 1
	if Input.is_action_pressed("ui_down"):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

		# Calcular dirección forward y right basada en la rotación de la cámara
		var forward = Vector3(0, 0, -1).rotated(Vector3.UP, deg_to_rad(camera_rotation.x))
		var right = Vector3(1, 0, 0).rotated(Vector3.UP, deg_to_rad(camera_rotation.x))

		var velocity = (forward * input_dir.y + right * input_dir.x) * 10
		player.velocity = velocity
	else:
		player.velocity = Vector3.ZERO

	player.move_and_slide()

	if pivot:
		pivot.rotation_degrees.y = camera_rotation.x
		pivot.rotation_degrees.x = camera_rotation.y

func _input(event):
	if event is InputEventKey and event.keycode == KEY_L and event.pressed:
		file_dialog.popup()
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.x -= event.relative.x * mouse_sensitivity
		camera_rotation.y -= event.relative.y * mouse_sensitivity
		camera_rotation.y = clamp(camera_rotation.y, -90, 90)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
			var world_pos = Vector3(x * tile_size, 0, y * tile_size)
			match symbol:
				"#":
					spawn_wall(world_pos)
				".":
					spawn_floor(world_pos)
				"P":
					spawn_floor(world_pos)
					spawn_player(world_pos)

func spawn_3d_floor(pos: Vector3) -> void:
	var mesh_instance = MeshInstance3D.new()
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(tile_size, tile_size)
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	add_child(mesh_instance)

func spawn_wall(pos: Vector3) -> void:
	var body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(tile_size, tile_size, tile_size)
	collision.shape = shape
	body.position = pos + Vector3(0, tile_size * 0.5, 0)
	body.add_child(collision)
	add_child(body)

func spawn_floor(pos: Vector3) -> void:
	var mesh_instance = MeshInstance3D.new()
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(tile_size, tile_size)
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	add_child(mesh_instance)

func spawn_player(pos: Vector3) -> void:
	player = CharacterBody3D.new()
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = tile_size * 0.3
	shape.height = tile_size * 0.8
	collision.shape = shape
	player.add_child(collision)

	var mesh_instance = MeshInstance3D.new()
	var mesh = CapsuleMesh.new()
	mesh.radius = tile_size * 0.3
	mesh.height = tile_size * 0.8
	mesh_instance.mesh = mesh
	player.add_child(mesh_instance)

	player.position = pos + Vector3(0, tile_size * 0.5, 0)

	pivot = Node3D.new()
	pivot.position = Vector3(0, tile_size * 0.5, 0)
	player.add_child(pivot)

	var camera = Camera3D.new()
	camera.position = Vector3(0, tile_size * 1.5, tile_size * 2)
	pivot.add_child(camera)

	add_child(player)

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/001-menu/menu.tscn")
