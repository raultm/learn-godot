extends Control

const SCENES_ROOT = "res://scenes"
const PROGRESS_FILE = "user://progress.cfg"

var all_scenes : Array = []
var max_unlocked : int = 0

@onready var root_container: VBoxContainer = VBoxContainer.new()
@onready var path_container: HBoxContainer = HBoxContainer.new()
@onready var steps_container: VBoxContainer = VBoxContainer.new()
@onready var progress_label: Label = Label.new()

func _ready() -> void:
	# UI construido completamente desde script
	root_container.name = "Root"
	root_container.anchors_preset = Control.PRESET_FULL_RECT
	# El nodo ya se ancla a todo el rectángulo; los márgenes se pueden ajustar con un contenedor padre si se desea.
	root_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root_container)

	var title = Label.new()
	title.text = "Camino de conocimiento"
	title.add_theme_font_size_override("font_size", 30)
	root_container.add_child(title)

	path_container.name = "PathLine"
	root_container.add_child(path_container)

	steps_container.name = "StepsList"
	root_container.add_child(steps_container)

	progress_label.name = "ProgressInfo"
	root_container.add_child(progress_label)

	var hint = Label.new()
	hint.text = "Pulsa un paso para navegar. Los pasos bloqueados se irán desbloqueando al completar niveles."
	hint.add_theme_font_size_override("font_size", 14)
	root_container.add_child(hint)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_container.add_child(spacer)

	all_scenes = _find_all_scene_files(SCENES_ROOT)
	if all_scenes.is_empty():
		title.text = "No hay escenas encontradas en scenes/."
		return

	all_scenes = _sort_scene_path_list(all_scenes)
	max_unlocked = _load_progress()
	if max_unlocked >= all_scenes.size():
		max_unlocked = all_scenes.size() - 1

	_update_progress_info()
	_render_path_line()
	_render_steps_list()

func _find_all_scene_files(dir_path: String) -> Array:
	var result: Array = []
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return result

	dir.list_dir_begin()
	var name = dir.get_next()
	while name != "":
		# Omitir directorios invisibles y referencias . y ..
		if name == "." or name == "..":
			name = dir.get_next()
			continue

		var path = dir_path.path_join(name)
		if dir.current_is_dir():
			result += _find_all_scene_files(path)
		elif name.to_lower().ends_with(".tscn"):
			result.append(path)
		name = dir.get_next()
	dir.list_dir_end()
	return result

func _sort_scene_path_list(list_paths: Array) -> Array:
	list_paths.sort_custom(Callable(self, "_scene_path_cmp"))
	return list_paths

func _scene_path_cmp(a, b):
	var a_name = a.get_file().get_basename()
	var b_name = b.get_file().get_basename()
	var a_key = _extract_order_key(a_name)
	var b_key = _extract_order_key(b_name)
	if a_key != b_key:
		return a_key - b_key
	return a_name.casecmp_to(b_name)

func _extract_order_key(name: String) -> int:
	var digits = ""
	for c in name:
		if c >= "0" and c <= "9":
			digits += c
		else:
			break
	if digits == "":
		return 9999
	return digits.to_int()

func _friendly_scene_name(scene_path: String) -> String:
	var name = scene_path.get_file().get_basename()
	var i = 0
	while i < name.length() and name[i] >= "0" and name[i] <= "9":
		i += 1
	if i < name.length() and name[i] in ["-", "_", ".", " "]:
		name = name.substr(i + 1, name.length())
	elif i > 0:
		name = name.substr(i, name.length())
	name = name.replace("_", " ").replace("-", " ")
	name = name.strip_edges()
	if name.length() > 0:
		name = name[0].to_upper() + name.substr(1)
	return name

func _render_path_line() -> void:
	for child in path_container.get_children():
		child.queue_free()
	for i in range(all_scenes.size()):
		var dot = Label.new()
		var completed = i <= max_unlocked
		dot.text = "●"
		# dot.add_theme_color_override("font_color", completed ? Color(0.2, 0.8, 0.4) : Color(0.6, 0.6, 0.6))
		dot.add_theme_font_size_override("font_size", 22)
		path_container.add_child(dot)

		if i < all_scenes.size() - 1:
			var line = Label.new()
			line.text = "───"
			line.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			line.add_theme_font_size_override("font_size", 18)
			path_container.add_child(line)

func _render_steps_list() -> void:
	for child in steps_container.get_children():
		child.queue_free()

	for i in range(all_scenes.size()):
		var scene_path = all_scenes[i]
		var button = Button.new()
		button.text = "%d. %s" % [i + 1, _friendly_scene_name(scene_path)]
		button.toggle_mode = false
		button.disabled = i > max_unlocked
		var cb = Callable(self, "_on_scene_button_pressed").bind(scene_path, i)
		button.connect("pressed", cb)
		steps_container.add_child(button)

func _on_scene_button_pressed(scene_path: String, index: int) -> void:
	if get_tree().change_scene_to_file(scene_path) == OK:
		_save_progress(index)

func _load_progress() -> int:
	var cfg = ConfigFile.new()
	var err = cfg.load(PROGRESS_FILE)
	if err != OK:
		return 0
	return int(cfg.get_value("menu", "max_unlocked", 0))

func _save_progress(index: int) -> void:
	max_unlocked = max(max_unlocked, index)
	var cfg = ConfigFile.new()
	cfg.set_value("menu", "max_unlocked", max_unlocked)
	cfg.save(PROGRESS_FILE)
	_update_progress_info()

func _update_progress_info() -> void:
	var current = max_unlocked + 1
	var total = all_scenes.size()
	progress_label.text = "Progreso: %d/%d pasos desbloqueados" % [current, total]

func _on_inicio_pressed() -> void:
	print("Inicio pressed")
