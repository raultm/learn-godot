extends Node

# Funciones comunes para cargar niveles

static func setup_common(node: Node, level_path: String, default_level: String) -> void:
	if level_path == "" or level_path == null:
		level_path = default_level

	if not load_level(node, level_path):
		push_error("No se pudo cargar el nivel: %s" % level_path)
		return

	build_level_common(node)

	# Crear el FileDialog
	var file_dialog = FileDialog.new()
	file_dialog.filters = ["*.txt"]
	file_dialog.file_selected.connect(node._on_file_selected)
	node.add_child(file_dialog)
	node.file_dialog = file_dialog

	# Botón para volver al menú (en CanvasLayer para que sea fijo en pantalla)
	var canvas_layer = CanvasLayer.new()
	var back_button = Button.new()
	back_button.text = "Volver al Menú"
	back_button.position = Vector2(10, 10)
	back_button.connect("pressed", Callable(node, "_on_back_to_menu"))
	canvas_layer.add_child(back_button)
	node.add_child(canvas_layer)
	node.canvas_layer = canvas_layer

static func load_level(node: Node, path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("No existe: " + path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir: " + path)
		return false

	node.grid.clear()

	while not file.eof_reached():
		node.grid.append(file.get_line())

	file.close()
	return true

static func build_level_common(node: Node) -> void:
	for y in range(node.grid.size()):
		var line = node.grid[y]

		for x in range(line.length()):
			var symbol = line[x]
			var world_pos = node.get_world_pos(x, y)

			match symbol:
				"#":
					node.spawn_wall(world_pos)
				".":
					node.spawn_floor(world_pos)
				"P":
					node.spawn_floor(world_pos)
					node.spawn_player(world_pos)

static func clear_level(node: Node) -> void:
	for child in node.get_children():
		if child != node.file_dialog and child != node.canvas_layer:
			child.queue_free()
	node.player = null  # resetear el player

static func process_movement(node: Node, delta: float) -> void:
	if node.player == null:
		return  # todavía no se ha creado el jugador

	var velocity = node.get_velocity_vector()

	if velocity != node.get_zero_vector():
		velocity = velocity.normalized() * node.get_speed()
	node.player.velocity = velocity
	node.player.move_and_slide()
