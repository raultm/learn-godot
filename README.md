# Aprender Godot

## 1. Menu

### 1.1 Crear Menu

1. Abrir Godot
2. Nueva Escena (Interfaz de Usuario)
3. Añadir nodo de boton
4. Jugar cambiando colores y textos en propiedades
5. Crear script para escena
6. Vincular boton con metodo a través de señal
7. Comprobar print("Inicio pressed")

### 1.2 Export to Html

1. Forward+ -> Mobile (Reinicio)
2. Editor -> Plantillas de Exportacion (Descargar e instalar)
3. Proyecto -> Exportar

### Recursos
- [Create MAIN MENU for your Godot game](https://www.youtube.com/watch?v=zHYkcJyE52g)
- [Export Your Game to the WEB with Godot 4](https://www.youtube.com/watch?v=91N9GqFjy_c)

## 2 Pintar nivel a partir de texto

### 2.1 Primer acercamiento

1.  Preparar Entorno
    1. Crear carpeta `res://levels/`
    2. Crear archivo `res://levels/level_01.txt`
```
########
#......#
#..P...#
#......#
########
```
`#` pared, `.` suelo, `P` jugador

2.  Escena que pinta el nivel
    1. Crear Escena `Level2dTopDown.tscn` (2d Vista desde arriba)
    2. Estructura `Node2D`
    3. Añadir script

3. Script funcional
```
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
```

4. Poner escena como la principal y arrancar proyecto
    1. En el nodo entre las propiedades modificar `level_path` con contenido `res://levels/level_01.txt`
    2. Poner escena como principal `Proyecto -> Configuracion del proyecto - Aplicacion - Ejecutar - Escena Principal`

5. Ejecutar. MAJIA!
