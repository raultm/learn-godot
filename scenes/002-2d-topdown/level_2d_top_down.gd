extends Node2D
@export var level_path : String
@export var tile_size : int = 32
const DEFAULT_LEVEL := "res://levels/level_01.txt"

var grid := []
var player : CharacterBody2D  # cambiar a CharacterBody2D
var file_dialog : FileDialog
var canvas_layer : CanvasLayer
var build_service : BuildLevel

func _ready():
	if level_path == "" or level_path == null:
		level_path = DEFAULT_LEVEL

	if not load_level(level_path):
		push_error("No se pudo cargar el nivel: %s" % level_path)
		return
	
	# Crear el FileDialog
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

func _input(event):
	if event is InputEventKey and event.keycode == KEY_L and event.pressed:
		file_dialog.popup()

func _on_file_selected(path):
	clear_level()
	load_level(path)

func clear_level():
	for child in get_children():
		if child != file_dialog and child != canvas_layer:
			child.queue_free()
	player = null  # resetear el player

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
	var parser = LevelParser.new()
	var renderer = LevelRenderer2D.new()

	build_service = BuildLevel.new(parser, renderer)

	player = build_service.execute(grid, self, tile_size)
	return true

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

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/001-menu/menu.tscn")
