extends Node3D

@export var level_path : String
@export var tile_size : float = 1.0
@export var camera_height : float = 8.0
@export var camera_angle : float = 45.0  # Ángulo en grados
const DEFAULT_LEVEL := "res://levels/level_01.txt"

var grid := []
var player : CharacterBody3D
var file_dialog : FileDialog
var canvas_layer : CanvasLayer
var tiles := []

func _ready() -> void:
	set_process(true)
	set_physics_process(true)

	if level_path == "" or level_path == null:
		level_path = DEFAULT_LEVEL

	print("3D Tilted (Top-Down 3/4): cargando nivel ", level_path)

	if not load_level(level_path):
		push_error("No se pudo cargar el nivel: %s" % level_path)
		return

	print("3D Tilted: grid", grid)
	setup_camera()
	build_level()

	# FileDialog para cambiar nivel con tecla L
	file_dialog = FileDialog.new()
	file_dialog.filters = ["*.txt"]
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)

	# Botón para volver al menú
	self.canvas_layer = CanvasLayer.new()
	var back_button = Button.new()
	back_button.text = "Volver al Menú"
	back_button.position = Vector2(10, 10)
	back_button.connect("pressed", Callable(self, "_on_back_to_menu"))
	self.canvas_layer.add_child(back_button)
	add_child(self.canvas_layer)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func setup_camera() -> void:
	# Crear cámara ortográfica para vista isométrica
	var camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 25.0
	
	# Posicionar cámara en ángulo 3/4 (45 grados)
	var angle_rad = deg_to_rad(camera_angle)
	camera.position = Vector3(
		camera_height * sin(angle_rad),
		camera_height * cos(angle_rad),
		camera_height * sin(angle_rad)
	)
	camera.look_at(Vector3(0, 0, 0), Vector3.UP)
	add_child(camera)
	camera.current = true

func _process(delta: float) -> void:
	if player == null:
		return

	var velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity.z -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.z += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	if velocity != Vector3.ZERO:
		velocity = velocity.normalized() * 5.0
	
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
	for tile in tiles:
		tile.queue_free()
	tiles.clear()
	
	if player != null:
		player.queue_free()
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
				"#":  # Muro
					var wall = create_tile(world_pos, Color(0.5, 0.5, 0.5))
					tiles.append(wall)
				".":  # Suelo
					var floor = create_tile(world_pos, Color(0.8, 0.8, 0.8))
					tiles.append(floor)
				"P":  # Player
					create_player(world_pos)
				"E":  # Enemy
					var enemy = create_tile(world_pos, Color.RED)
					tiles.append(enemy)

func create_tile(pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(tile_size, 0.5, tile_size)
	mesh_instance.mesh = box_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.set_surface_override_material(0, mat)
	
	mesh_instance.position = pos + Vector3(0, 0.25, 0)
	add_child(mesh_instance)
	
	return mesh_instance

func create_player(pos: Vector3) -> void:
	player = CharacterBody3D.new()
	player.position = pos
	
	# Crear mesh del jugador (esfera o cubo pequeño)
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = tile_size * 0.3
	sphere_mesh.height = tile_size * 0.6
	mesh_instance.mesh = sphere_mesh
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.BLUE
	mesh_instance.set_surface_override_material(0, mat)
	
	player.add_child(mesh_instance)
	
	# Agregar colisionador
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = CapsuleShape3D.new()
	collision_shape.shape.radius = tile_size * 0.3
	collision_shape.shape.height = tile_size * 0.6
	player.add_child(collision_shape)
	
	add_child(player)

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/001-menu/menu.tscn")
